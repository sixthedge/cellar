class ThinkspaceTrackerSio

  constructor: (@platform) ->
    @util        = @platform.util
    @tracker     = @platform.tracker
    @debug_color = @tracker.debug_color

  on_connection: (socket) ->
    socket.on @util.client_event('tracker_sio_join'),  (data) => @join_rooms(socket, data)
    socket.on @util.client_event('tracker_sio_leave'), (data) => @leave_rooms(socket, data)

  # The room join/leave do not use the authentication/authorization process
  # as this is not a 'room type' and the events are handled here.
  # Trackers must still be authorized by the Rails server.

  join_rooms: (socket, data) ->
    rooms = @util.data_rooms(data)
    return if @util.is_array_blank(rooms)
    if @util.debugging
      @util.debug @util.bold_line("TRACKER SIO JOIN ROOMS\n", @debug_color), {rooms, data}
    for room in rooms
      socket.join(room, => @join_room_callback(socket, room, data))

  join_room_callback: (socket, room, data) -> @tracker.join_room(socket, room, data)

  leave_room: (socket, data) ->
    rooms = @util.data_rooms(data)
    return if @util.is_array_blank(rooms)
    for room in @util.make_array(rooms)
      socket.leave(room, => @leave_room_callback(socket, rooms))

  leave_room_callback: (socket, room) -> @tracker.leave_room(socket, room, data)

  to_string: -> 'ThinkspaceTrackerSio'

module.exports = ThinkspaceTrackerSio
