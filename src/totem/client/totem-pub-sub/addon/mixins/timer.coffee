import ember from 'ember'

export default ember.Mixin.create

  emit_timer_show: (options={}) ->
    rooms      = @get_options_rooms(options)
    @error("Timer show emit requires a room.") if ember.isBlank(rooms)
    room_event = @get_options_room_event(options) or 'timer'  # the node server message server event (e.g. not the event to trigger a timer show)
    event      = 'timer_show' # event the node server is listening to send the timer data
    room_type  = null
    socket     = @get_socket()
    cevent     = @client_event(event)
    socket.emit(cevent, {rooms, room_event})

