import ember from 'ember'

export default ember.Mixin.create

  # ###
  # ### Public API.
  # ###

  # Return a socket with authenticate and authorize events.
  auth_socket: (options) ->
    return null unless @pubsub_active
    url = @get_pubsub_url(options)
    @error("Pubsub url is blank.")  if ember.isBlank(url)
    socket = @url_to_socket_map.get(url)
    @auth_authenticate_callback(socket, options)
    return socket if socket
    socket = @io.connect(url);
    @error("Pubsub socket is blank [url: #{url}].")  unless socket
    @url_to_socket_map.set(url, socket)
    @auth_socket_events(socket)
    socket

  # ###
  # ### Private.
  # ###

  # The 'auth_options_map' should only include options that are needed to authorize (or re-authorize)
  # such as strings or an array of strings (e.g. rooms, etc.).  Event specific data such as
  # components and callbacks are stored separately in the events map and are not needed to authorize.
  # If include event data, cannot match similar authorize requests and will be duplicated.
  # A socket.io server authorize request will only return the 'auth_key' when present.
  # Re-authorize happens if the page is re-loaded or the node socket.io server is re-started.

  url_to_socket_map: ember.Map.create()
  auth_options_map:  ember.Map.create()

  auth_socket_events: (socket) ->
    socket.on 'connect', =>
      @set_not_authenticated(socket)
      auth = @get_auth_query()
      socket.emit @client_event('authenticate'), {auth}
      console.warn 'connect:', socket.id, socket, auth
    socket.on @server_event('authenticated'),             => @authenticate_success(socket)
    socket.on @server_event('authorized'),         (data) => @authorize_success(socket, data)
    socket.on @server_event('not_authenticated'),  (data) => @authenticate_error(socket, data)
    socket.on @server_event('not_authorized'),     (data) => @authorize_error(socket, data)

  # ###
  # ### Authenticate.
  # ###

  auth_authenticate_callback: (socket, options) ->
    auth_key = @get_auth_key_for_options(options)
    if @is_authenticated(socket)
      @call_auth_callback(options.authenticate_callback, socket, {auth_key})
      @call_after_authenticate_callback(options)

  authenticate_success: (socket) ->
    @set_is_authenticated(socket)
    socket.authorized = {}
    @auth_options_map.forEach (options, auth_key) =>
      @call_auth_callback(options.authenticate_callback, socket, {auth_key})
      @call_after_authenticate_callback(options)

  authenticate_error: (socket, data) ->
    @invalidate_socket(socket)
    @error '=> not authenticated:', data.message

  # ###
  # ### Authorize.
  # ###

  authorize_success: (socket, data) ->
    options = @get_data_auth_key_options(data)
    @call_auth_callback(options.authorize_callback, socket, data)

  authorize_error: (socket, data) ->
    @invalidate_socket(socket)
    @error '=> not authorized:', data.message

  # ###
  # ### Helpers.
  # ###

  # If the options alreay exist in the map, return the key, otherwise save the options with a generated key.
  get_auth_key_for_options: (options) ->
    options_key = null
    @auth_options_map.forEach (opts, key) =>
      options_key = key  if not options_key and @objects_equal(options, opts)
    return options_key  if options_key
    key = ember.guidFor(options)
    @auth_options_map.set(key, options)
    key

  get_data_auth_key_options: (data) -> if (key = @get_data_auth_key(data)) then (@auth_options_map.get(key) or {}) else {}

  call_auth_callback: (callback, args...) ->
    return unless @is_string(callback)
    return unless @is_function(@[callback])
    @[callback](args...)

  call_after_authenticate_callback: (options) ->
    callback = options.after_authenticate_callback
    source   = options.source
    if ember.isPresent(callback) and ember.isPresent(source)
      source[callback](options) if @is_active(source) and @is_function(source[callback])

  get_auth_query: ->
    query = {}
    token = @auth_session_token()
    email = @current_user_email()
    @error("User token is blank.")  if ember.isBlank(token)
    @error("User email is blank.")  if ember.isBlank(email)
    query.auth = {token, email}
    @add_ownerable_to_query(query)
    @add_authable_to_query(query)
    query.auth

  auth_session_token: ->
    session = @get('session')
    session and session.get_token()

  is_authenticated:      (socket) -> socket and socket.authenticated == true
  set_is_authenticated:  (socket) -> socket and socket.authenticated = true
  set_not_authenticated: (socket) -> socket and socket.authenticated = false
  get_authorized:        (socket) -> socket.authorized or (socket.authorized = {})
