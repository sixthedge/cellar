import ember from 'ember'

export default ember.Mixin.create

  get_tracker_sio_room: -> 'tracker_sio_room'

  tracker_sio_join_room: (options={}) ->
    room = options.room or @get_tracker_sio_room()
    data = @get_tracker_data(options)
    @pubsub.tracker_sio_join({room, data})

  tracker_sio_leave_room: (options={}) ->
    room = options.room or @get_tracker_sio_room()
    @pubsub.tracker_sio_leave({room})
