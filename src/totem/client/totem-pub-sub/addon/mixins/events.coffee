import ember    from 'ember'
import Callback from 'totem-pub-sub/callback'

export default ember.Mixin.create

  # ###
  # ### Public API.
  # ###

  server_event: (args...) -> "server:#{args.join('/')}"
  client_event: (args...) -> "client:#{args.join('/')}"

  on: (socket, event, source, callback) ->
    return unless @pubsub_active
    @error("First argument to 'pubsub.on' must be a socket not:", socket)                 unless @is_hash(socket) and socket.io
    @error("Second argument to 'pubsub.on' must be an event string not:", event)          unless event and @is_string(event)
    @error("Third argument to 'pubsub.on' must be the callback source not:.", source)     unless source and @is_hash(source)
    @error("Fouth argument to 'pubsub.on' must be a callback function string:", callback) unless callback and @is_string(callback)
    @add_current_event(socket, event, source, callback)
    unless socket.hasListeners(event)
      pubsub_callback = @new_socketio_on_callback(socket, event)
      socket.on event, pubsub_callback.fn

  # ###
  # ### Private.
  # ###

  # ###
  # current_events_map[socket] ->
  #     map[event] ->
  #         map[source] -> [callback, callback, ...]
  # The events and callbacks are strings.
  current_events_map: ember.Map.create()

  add_current_event: (socket, event, source, callback) ->
    events_map   = @get_key_map(@current_events_map, socket)
    event_map    = @get_key_map(events_map, event)
    source_array = @get_key_map_value_array(event_map, source)
    source_array.push(callback)  unless source_array.includes(callback)

  new_socketio_on_callback: (socket, event) -> new Callback(@, socket, event)

  call_event_callback: (socket, event, args) ->
    return unless @socket_is_connected(socket)
    events_map = @get_key_map(@current_events_map, socket)
    event_map  = @get_key_map(events_map, event)
    event_map.forEach (callbacks, source) =>
      if @is_active(source)
        callback_array = @get_key_map_value_array(event_map, source) or []
        for callback in callback_array
          source[callback](args...) if @is_function(source[callback])

  delete_current_events_for_room: (socket, room, room_type) ->
    events_map = @current_events_map.get(socket)
    return if ember.isBlank(events_map)
    auth_room_types = @get_authorized_room_types(socket)
    events = []
    regex  = new RegExp("^server:#{room}")
    events_map.forEach (event_map, event) =>
      if event.match(regex)
        event_or_type = event.replace(regex,'')
        event_or_type = event_or_type.replace(/:.*/,'')
        event_or_type = event_or_type.replace(/^\//,'')
        if ember.isBlank(room_type)
          if ember.isBlank(auth_room_types) or ember.isBlank(event_or_type)
            events.push(event)
          else
            events.push(event) unless auth_room_types.includes(event_or_type)
        else
          events.push(event) if auth_room_types.includes(event_or_type)
    if @debugging_delete_events
      console.warn 'delete events:', socket
      console.info('   ', event) for event in events
    @delete_current_event(socket, event) for event in events

  delete_current_event: (socket, event) ->
    events_map = @current_events_map.get(socket)
    return if ember.isBlank(events_map)
    events_map.delete(event)
    socket.off(event)

  get_authorized_room_types: (socket) ->
    rooms = @get_authorized_rooms(socket) or []
    types = []
    for room, tf of rooms
      [temp, type] = room.split('::', 2)
      types.push(type) if ember.isPresent(type)
    types

  clean_up_current_events_map: ->
    @current_events_map.forEach (events_map, socket) =>
      if @socket_is_connected(socket)
        events_map.forEach (event_map, event) =>
          event_map.forEach (callbacks, source) =>
            unless @is_active(source)
              event_map.delete(source)
      else
        @current_events_map.delete(socket)

  print_current_events: (title='') ->
    if @current_events_map.size > 0
      console.warn "Current Events#{title}:"
      @current_events_map.forEach (events_map, socket) =>
        if events_map.size > 0
          console.info '   Socket:', socket
          events_map.forEach (source_map, event) =>
            if source_map.size > 0
              console.info '      *' + event
              source_map.forEach (callbacks, source) =>
                console.info '          active:', @is_active(source), source.toString(), callbacks
    else
      console.warn "Current Events#{title}: None."

  socket_is_connected: (socket) -> socket and socket.connected

