import ember from 'ember'

export default ember.Mixin.create

  use_tracker_sio: true

  get_tracker_room:           -> if @get('use_tracker_sio') then @get_tracker_sio_room() else 'tracker_room'
  tracker:       (options={}) -> if @get('use_tracker_sio') then @tracker_sio_join_room(options)  else @tracker_join_room(options)
  tracker_leave: (options={}) -> if @get('use_tracker_sio') then @tracker_sio_leave_room(options) else @tracker_leave_room(options)

  tracker_leave_room: (options={}) ->
    room = options.room or @get_tracker_room()
    @pubsub.tracker_leave({room})

  tracker_join_room: (options={}) ->
    room = options.room or @get_tracker_room()
    data = @get_tracker_data(options)
    @pubsub.tracker({room, data})

  get_tracker_data: (options={}) ->
    route  = options.route
    model  = {}
    data   = {route, model}
    record = @thinkspace.get_current_model()
    if ember.isPresent(record)
      data.title      = record.get('title')
      data.id         = record.get('id')
      data.model_name = @get_totem_scope().record_model_name(record)
      model.title     = record.get('title')
      model.id        = record.get('id')
      model.name      = @get_totem_scope().record_model_name(record)
    data
