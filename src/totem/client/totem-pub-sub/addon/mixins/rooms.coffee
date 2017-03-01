import ember from 'ember'
import ns    from 'totem/ns'
import util  from 'totem/util'
import totem_scope from 'totem/scope'

export default ember.Mixin.create

  # ###
  # ### Public API.
  # ###

  join: (options={}) ->
    return unless @pubsub_active
    source    = @get_options_source(options)
    rooms     = @get_options_rooms(options)
    callbacks = @get_options_callbacks(options) or []
    room_type = @get_options_room_type(options)
    @error("Join rooms are blank.") if ember.isBlank(rooms)
    @error("Must supply a 'source:' option for callbacks.") if ember.isPresent(callbacks) and not source
    options.authenticate_callback = 'room_join_authenticate_callback'
    options.authorize_callback    = 'room_join_authorize_callback'
    @delete_join_room_event_only_keys(options)
    socket = @get_socket(options)
    for room in rooms
      event    = @room_event(room, options)
      callback = callbacks.shift()
      @on(socket, event, source, callback)  if callback
      @add_after_authorize_callback_event(socket, source, event, options)
    socket

  add_after_authorize_callback_event: (socket, source, event, options) ->
    after_authorize_callback = options.after_authorize_callback
    return if ember.isBlank(after_authorize_callback)
    auth_event = @get_after_authorize_callback_event(event)
    @add_current_event(socket, auth_event, source, after_authorize_callback)

  leave: (options={}) ->
    return unless @pubsub_active
    rooms = @get_options_rooms(options)
    return if ember.isBlank(rooms)
    room_type = @get_options_room_type(options)
    socket    = @get_socket(options)
    event     = @client_event('leave_room')
    @set_rooms_unauthorized(socket, rooms, room_type)
    for room in rooms
      data           = {room}
      data.room_type = room_type  if room_type
      socket.emit(event, data)

  leave_all: (options={}) ->
    return unless @pubsub_active
    url = @get_pubsub_url(options)
    return if ember.isBlank(url)
    socket = @url_to_socket_map.get(url)
    return if ember.isBlank(socket)
    auth_rooms = @get_authorized_rooms(socket)
    return if ember.isBlank(auth_rooms)
    except = ember.makeArray(options.except or [])
    rooms  = @get_object_keys(auth_rooms).map (room) -> room.split('::')
    for [room, room_type] in rooms
      @leave {room, room_type} unless except.includes(room)

  message_to_room:    (room, data)  -> @message_to_rooms(room, data)
  broadcast_to_room:  (room, data)  -> @broadcast_to_rooms(room, data)
  message_to_rooms:   (rooms, data) -> @message_to_rooms_members @room_message_event(),   rooms, data
  broadcast_to_rooms: (rooms, data) -> @message_to_rooms_members @room_broadcast_event(), rooms, data

  message_to_room_members:  (event, room, data)  -> @message_to_rooms_members(event, room, data)
  message_to_rooms_members: (event, rooms, data) ->
    return unless @pubsub_active
    @error("Member room message events are blank.") if ember.isBlank(event)
    @error("Event '#{event}' rooms are blank.")     if ember.isBlank(rooms)
    rooms     = ember.makeArray(rooms)
    room_type = @get_options_room_type(data)
    socket    = @get_socket()
    if @is_authenticated(socket) and @are_rooms_authorized(socket, rooms, room_type)
      data.rooms = rooms
      socket.emit event, data
    else
      @queue_events_room_data(data, rooms: rooms, room_type: room_type, events: event)

  # ### Public API: Room Event Helpers. ### #

  room_message_event:   -> @client_event('room_message')
  room_broadcast_event: -> @client_event('room_broadcast')

  room_event: (room, options={}) ->
    event = [room]
    event.push options.room_type  if options.room_type
    event.push options.room_event if options.room_event
    @server_event(event...)

  # ### Public API: Room Name Helpers. ### #

  room_with_current_user: (arg, args...) ->
    return null if ember.isBlank(arg)
    user = totem_scope.get_current_user()
    return null unless user
    args.unshift user.get('id')
    args.unshift @model_path(user)
    @room_for(arg, args)

  room_with_ownerable: (arg, args...) ->
    return null if ember.isBlank(arg)
    ownerable = totem_scope.get_ownerable_record()
    return null unless ownerable
    args.unshift ownerable.get('id')
    args.unshift @model_path(ownerable)
    @room_for(arg, args)

  room_for: (arg, args...) ->
    switch
      when @is_string(arg)  then room = arg
      when @is_record(arg)  then room = @room_for_model(arg)
      else room = null
    return null if ember.isBlank(room)
    return room if ember.isBlank(args)
    args = util.flatten_array(args)
    room + '/' + args.join('/')

  room_for_model: (record) -> @model_path(record) + "/#{record.get('id')}"

  # ###
  # ### Private.
  # ###

  delete_join_room_event_only_keys: (options) ->
    delete(options.source)
    delete(options.callback)
    delete(options.callbacks)

  # ###
  # ### Callbacks.
  # ###

  room_join_authenticate_callback: (socket, data) ->
    options       = @get_data_auth_key_options(data)
    rooms         = @get_options_rooms(options)
    room_type     = @get_options_room_type(options)
    room_event    = @get_options_room_event(options)
    room_observer = @get_options_room_observer(options)
    return if ember.isBlank(rooms)
    @clean_up_current_events_map(socket)
    if @are_rooms_authorized(socket, rooms, room_type)
      @emit_queued_room_events()
      return
    return if @are_rooms_pending_authorization(socket, rooms, room_type)
    @set_rooms_pending_authorization(socket, rooms, room_type)
    auth     = @get_auth_query()
    auth_key = @get_data_auth_key(data)
    socket.emit @client_event('authorize'), {auth, auth_key, rooms, room_type, room_event, room_observer}

  room_join_authorize_callback: (socket, data) ->
    return unless @is_authenticated(socket)
    options   = @get_data_auth_key_options(data)
    rooms     = @get_options_rooms(options)
    room_type = @get_options_room_type(options)
    return if ember.isBlank(rooms)
    @set_rooms_authorized(socket, rooms, room_type)
    @emit_queued_room_events(socket)
    @after_authorize_callback(socket, options, rooms, room_type, data)

  # An authorize callback is useful when the node-socketio server is restarted.
  # After a restart of the node-socketio server, each authorize request is re-sent
  # and the after_authorize-callback called.  Typically, the callback would send
  # a socketio request to populate some data (is only applicable when this is needed).

  after_authorize_callback: (socket, options, rooms, room_type, data) ->
    callback = options.after_authorize_callback
    return if ember.isBlank(callback)
    for room in rooms
      event      = @room_event(room, options)
      auth_event = @get_after_authorize_callback_event(event)
      events_map = @current_events_map.get(socket)
      return if ember.isBlank(events_map)
      source_map = events_map.get(auth_event)
      return if ember.isBlank(source_map)
      source_map.forEach (temp, source) =>
        source[callback](options) if @is_active(source) and @is_function(source[callback])

  get_after_authorize_callback_event: (event) ->
    auth_event = if ember.isBlank(event) then 'auth_event' else "#{event}"
    "#{auth_event}:after_authorize_callback"

  # ###
  # ### Queue Events and Rooms Data.
  # ###

  # ###
  # event_room_data_map[event] ->
  #     map[room_id] -> [data, data, ...]
  event_room_data_map: ember.Map.create()

  queue_events_room_data: (data, options) ->
    rooms     = @get_options_rooms(options)
    room_type = @get_options_room_type(options)
    events    = @get_options_events(options)
    return if ember.isBlank(rooms)
    return if ember.isBlank(events)
    for event in events
      room_map = @get_key_map(@event_room_data_map, event)
      for room in rooms
        room_id = @get_authorized_room_id(room, room_type)
        room_data_array = @get_key_map_value_array(room_map, room_id)
        room_data_array.push(ember.merge {}, data)

  emit_queued_room_events: (socket) ->
    @event_room_data_map.forEach (room_map, event) =>
      room_map.forEach (data_array, room) =>
        if @are_rooms_authorized(socket, [room])
          room_map.delete(room)
          room = room.split('::')[0]  # remove the room_type (if exists)
          if ember.isBlank(data_array)
            socket.emit(event, {room})
          else
            for data in data_array
              data.rooms = room
              socket.emit(event, data)

  # ###
  # ### Helpers.
  # ###

  set_rooms_authorized:            (socket, rooms, room_type=null) -> @set_rooms_authorized_value(socket, rooms, room_type, true)
  set_rooms_pending_authorization: (socket, rooms, room_type=null) -> @set_rooms_authorized_value(socket, rooms, room_type, 'pending')

  set_rooms_unauthorized: (socket, rooms, room_type=null) ->
    authorized = @get_authorized_rooms(socket)
    for room in rooms
      room_id = @get_authorized_room_id(room, room_type)
      @delete_current_events_for_room(socket, room, room_type)
      @delete_auth_callbacks_for_room(socket, room, room_type)
      delete(authorized[room_id])

  delete_auth_callbacks_for_room: (socket, room, room_type) ->
    # Delete any authorization requests for the room being unauthorized
    # to prevent retrying the authorization when the socket.io server is restarted.
    # e.g. trat -> irat -> restart node server (team room is not authorized on the irat)
    delete_auth_keys = []
    @auth_options_map.forEach (options, auth_key) =>
      map_rooms     = @get_options_rooms(options)
      map_room_type = @get_options_room_type(options) or null
      if ember.isPresent(map_rooms) and ember.isArray(map_rooms)
        if room_type == map_room_type
          map_rooms = map_rooms.without(room)
          if ember.isBlank(map_rooms)
            delete_auth_keys.push(auth_key)
          else
            delete(options.room)
            delete(options.rooms)
            options.rooms = map_rooms # keep rooms other than for the deleted room
    if @debugging_delete_events
      console.warn '====delete auth callbacks:'
      console.info('   ', @auth_options_map.get(key)) for key in delete_auth_keys
    @auth_options_map.delete(auth_key) for auth_key in delete_auth_keys

  are_rooms_authorized: (socket, rooms, room_type=null) ->
    authorized = @get_authorized_rooms(socket)
    for room in rooms
      room_id = @get_authorized_room_id(room, room_type)
      return false if authorized[room_id] != true
    true

  are_rooms_pending_authorization: (socket, rooms, room_type=null) ->
    authorized = @get_authorized_rooms(socket)
    for room in rooms
      room_id = @get_authorized_room_id(room, room_type)
      state   = authorized[room_id]
      return false unless (state == true or state == 'pending')
    true

  get_authorized_room_id: (room, room_type) ->
    return room unless room_type
    room + '::' + room_type

  set_rooms_authorized_value: (socket, rooms, room_type, value) ->
    authorized = @get_authorized_rooms(socket)
    for room in rooms
      room_id             = @get_authorized_room_id(room, room_type)
      authorized[room_id] = value

  get_authorized_rooms: (socket) ->
    authorized = @get_authorized(socket)
    authorized.rooms or (authorized.rooms = {})

  print_event_room_data: (title='') ->
    if @event_room_data_map.size > 0
      console.warn "Event Room Data#{title}:"
      @event_room_data_map.forEach (room_map, event) =>
        console.info '   *event:', event
        if room_map.size > 0
          room_map.forEach (data, room) =>
            console.info '      *room:', room
            console.info '         *data:', data
        else
          console.info '      *No rooms.'
    else
      console.warn "Event Room Data#{title}: None."
