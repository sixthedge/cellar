import ember from 'ember'

export default ember.Mixin.create

  join_id_room_event: (source, event, id, callback=null) ->
    room       = @room
    room_event = @get_room_event_with_id(event, id)
    callback   = "handle_#{event}"  unless callback
    @pubsub.join {room, source, callback, room_event}

  join_room_event: (source, event, callback=null) ->
    room       = @room
    room_event = event
    callback   = "handle_#{event}"  unless callback
    @pubsub.join {room, source, callback, room_event}

  broadcast_id_room_event: (event, id, value=null) ->
    room_event = @get_room_event_with_id(event, id)
    data       = {room_event}
    data.value = value if value
    @pubsub.broadcast_to_room @room, data

  broadcast_to_room_event: (event, value=null) ->
    room_event = @get_room_event_with_id(event)
    data       = {room_event}
    data.value = value if value
    @pubsub.broadcast_to_room @room, data

  get_room_event_with_id: (event, id) -> "#{event}/#{id}"

  join_room: (options={}) ->
    options.room = @room unless options.room
    @pubsub.join(options)

  leave_room: (room_type=null) ->
    options           = {}
    options.room      = @room unless options.room
    options.room_type = room_type  if room_type
    @pubsub.leave(options)

  message_to_room_members: (event, options={}) ->
    rooms = options.room or options.rooms or @room
    delete(options.room)
    delete(options.rooms)
    @pubsub.message_to_rooms_members(event, rooms, options)
