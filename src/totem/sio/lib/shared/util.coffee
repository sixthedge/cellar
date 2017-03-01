class SocketIOUtil

  constructor: (@debugging=false) -> return

  server_event: (args...) -> "server:#{args.join('/')}"
  client_event: (args...) -> "client:#{args.join('/')}"

  as_json: (str) ->
    unless @is_string(str)
      message = "Invalid JSON [util.as_json]: Argument must be a string not '#{typeof(str)}'."
      @error(message)
      return {message}
    try
      json = JSON.parse(str)
    catch e
      message = "Invalid JSON [util.as_json]: #{e.message}"
      @error(message)
      json = {message}
    finally
      json

  env_var_int: (name, namespace=null) ->
    value = @env_var(name, namespace)
    if value.match(/^\d+$/) then parseInt(value) else null

  env_var: (name, namespace=null) ->
    if namespace
      ns = namespace.replace('/', '').toUpperCase()
      ns = "#{ns}_"
    else
      ns = ''
    name  = 'SIO_' + ns + name
    value = process.env[name]
    @debug "env: #{name}=#{value}"
    # If the first value is '$', proxy it to the related ENV.
    # Used to standardize the ENV to things like SIO_APP_PORT, but defer to Cloud provider set values (e.g. ENV['PORT'])
    if value && value[0] == '$' then value = process.env[value.substring(1)]
    value

  make_array: (obj) ->
    return [] unless obj
    if @is_array(obj) then obj else [obj]

  array_contains: (array, element) -> array.indexOf(element) != -1

  is_array:    (obj) -> obj and Array.isArray(obj)
  is_hash:     (obj) -> obj and typeof(obj) == 'object' and not @is_array(obj)
  is_string:   (str) -> str and typeof(str) == 'string'
  is_function: (fn)  -> fn  and typeof(fn)  == 'function'
  is_nan:      (n)   -> n   and isNaN(n)

  is_array_blank: (obj) ->
    return true unless obj
    return true unless @is_array(obj)
    obj.length == 0

  is_array_present: (obj) -> not @is_array_blank(obj)

  starts_with: (string, prefix) -> (string or '').indexOf(prefix) == 0

  timeout: (to) -> if to then parseInt(to) else 'none'

  hash_keys: (hash) -> (@is_hash(hash) and Object.keys(hash)) or []

  is_hash_present: (hash) -> @hash_keys(hash).length > 0

  # ###
  # ### Socket Helpers.
  # ###

  is_authenticated:      (socket) -> socket and socket.authenticated == true
  set_is_authenticated:  (socket) -> socket and socket.authenticated = true
  set_not_authenticated: (socket) -> socket and socket.authenticated = false

  set_not_authorized: (socket) -> socket and socket.authorized = false
  set_is_authorized:  (socket) -> socket and socket.authorized = true
  is_authorized:      (socket) -> socket and socket.authorized == true

  can_access: (socket) -> @is_authenticated(socket) and @is_authorized(socket)

  can_access_room: (socket, room) -> @can_access(socket) and ( @in_room(socket, room) or @is_superuser(socket) )

  disconnect: (socket) ->
    @debug '\n', 'disconnect sid:', socket.id
    socket.disconnect('close') # disconnect and close socket connection

  is_disconnected: (socket) -> not socket or socket.disconnected
  is_connected:    (socket) -> not @is_disconnected(socket)

  set_user_data: (socket, json) ->
    user_data = json.user_data or {}
    socket.auth_data ?= {}
    socket.auth_data.user = user_data

  get_user_data: (socket) -> (socket.auth_data or {}).user or {}
  get_user_id:   (socket) -> @get_user_data(socket).id or null

  is_superuser: (socket) -> @get_user_data(socket).superuser == true

  in_room: (socket, room) -> @get_rooms(socket)[room]

  get_rooms: (socket) -> socket.rooms or {}

  get_room_names: (socket) -> @hash_keys(@get_rooms(socket))

  # ###
  # ### Select Module Type Helpers.
  # ###

  room_modules:          (mods) -> (mods or []).filter (mod) => @is_string(mod.prototype.room_type)
  on_connection_modules: (mods) -> (mods or []).filter (mod) => @is_function(mod.prototype.on_connection)

  # ###
  # ### Data Helpers.
  # ###

  data_rooms: (data) ->
    rooms = data and (data.rooms or data.room)
    return null unless rooms
    @make_array(rooms)

  data_room_types: (data) ->
    types = data.room_types or data.room_type
    return null unless types
    @make_array(types)

  data_room_event: (data) -> data and data.room_event

  data_auth: (data) -> (data and data.auth) or {}

  data_response: (data) ->
    return {} unless @is_hash(data)
    auth_key = data.auth_key
    if auth_key then {auth_key} else data

  data_return_message: (data) ->
    value = data.value
    return {value}  if value
    return {}       if data.room_event
    data

  data_room_room_event: (room, data) ->
    event = [room]
    event.push data.room_type  if data.room_type
    event.push data.room_event if data.room_event
    @server_event(event...)

  # ###
  # ### Request Auth Header.
  # ###

  get_auth_data_and_header: (data) ->
    unless @is_hash(data)
      @error 'Auth request data is not a hash.', data
      return [null, null]
    auth = data.auth or {}
    unless @is_hash(auth)
      @error 'Auth request data.auth is not a hash.', data
      return [null, null]
    token = auth.token
    email = auth.email
    unless token
      @error 'Auth request auth token is blank.', data
      return [null, null]
    unless email
      @error 'Auth request auth email is blank.', data
      return [null, null]
    header = {'Authorization': "Token token=\"#{token}\", email=\"#{email}\""}
    delete(auth.token)
    delete(auth.email)
    [data, header]

  # ###
  # ### Console Messages.
  # ###

  sep: (n=80) -> Array(n).join('-')

  say: (args...) -> console.log args...

  info:  (messages...) -> @say @prepare_messages(messages, '[info ] ')...
  warn:  (messages...) -> @say @prepare_messages(messages, '[WARN ] ', 'yellow', true)...
  debug: (messages...) -> @debugging and @say @prepare_messages(messages, '[debug] ', 'green')...

  error: (messages...) ->
    @say @color_line('******************************', 'red')
    @say @prepare_messages(messages, '[ERROR]', 'red', true)...
    @say @color_line('------------------------------', 'red')

  prepare_messages: (messages, prefix='', color=null, bold=false) ->
    if messages[0] == '\n'
      @blank_line()
      messages.shift()
    prefix_msg = prefix + @message_date()
    prefix_msg = if bold then @bold_line(prefix_msg, color) else @color_line(prefix_msg, color)
    messages.unshift prefix_msg
    messages

  blank_line: -> @say('')

  message_date: -> "[#{new Date().toLocaleString()}]"

  source_name: (source) ->
    return '' unless source
    return '' unless @is_function(source.to_string)
    "[#{source.to_string()}]"

  color_line: (message, color=null) ->
    return message unless color
    color = @colors[color]
    return message unless color
    color + message + @colors.reset

  bold_line: (message, color=null) ->
    return @color_line(message, 'bold') unless color
    @colors.bold + @color_line(message, color) + @colors.reset

  colors:
    reset:     "\x1b[0m"
    hicolor:   "\x1b[1m"
    bold:      "\x1b[1m" # same as hicolor
    underline: "\x1b[4m"
    inverse:   "\x1b[7m"
    # foreground colors
    black:         "\x1b[30m"
    red:           "\x1b[31m"
    green:         "\x1b[32m"
    yellow:        "\x1b[33m"
    blue:          "\x1b[34m"
    magenta:       "\x1b[35m"
    cyan:          "\x1b[36m"
    white:         "\x1b[37m"
    light_red:     "\x1b[91m"
    light_green:   "\x1b[92m"
    light_yellow:  "\x1b[93m"
    light_blue:    "\x1b[94m"
    light_magenta: "\x1b[95m"
    light_cyan:    "\x1b[96m"

  throw_error: (source, message) ->
    message = "#{@message_date()} #{@source_name(source)} #{message}"
    throw new Error(message)

  to_string: -> 'SocketIOUtil'

module.exports = SocketIOUtil
