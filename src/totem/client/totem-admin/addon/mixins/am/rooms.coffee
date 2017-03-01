import ember from 'ember'

export default ember.Mixin.create

  room_list: (component) ->
    options =
      after_authenticate_callback: 'room_list_callback'
      source:                      @
      component:                   component
    @pubsub.get_socket(options) # authenticate the user

  room_list_callback: (options) -> @emit_room_list(options.component)

  emit_room_list: (source, callback='handle_room_list') ->
    event  = 'room_list'
    socket = @pubsub.get_socket()
    cevent = @pubsub.client_event(event)
    sevent = @pubsub.server_event(event)
    @pubsub.on(socket, sevent, source, callback)
    socket.emit(cevent)

  room_counts: (component) ->
    options =
      after_authenticate_callback: 'room_counts_callback'
      source:                      @
      component:                   component
    @pubsub.get_socket(options) # authenticate the user

  room_counts_callback: (options) -> @emit_room_counts(options.component)

  emit_room_counts: (source, callback='handle_room_counts') ->
    event  = 'room_counts'
    socket = @pubsub.get_socket()
    cevent = @pubsub.client_event(event)
    sevent = @pubsub.server_event(event)
    @pubsub.on(socket, sevent, source, callback)
    socket.emit(cevent)

  emit_room_count_reset: (hash) ->
    return if ember.isBlank(hash.room)
    event  = 'room_counts_reset'
    socket = @pubsub.get_socket()
    cevent = @pubsub.client_event(event)
    socket.emit(cevent, hash)
