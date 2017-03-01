import ember from 'ember'

export default ember.Mixin.create

  timer_show: (options={}) ->
    rooms = options.room or options.rooms
    @error "Timer show requires a room." if ember.isBlank(rooms)
    @pubsub.emit_timer_show({rooms})
