class ThinkspaceTracker

  room_type: 'tracker'

  constructor: (@platform) ->
    @util    = @platform.util
    @tracker = @platform.tracker

  on_connection: (socket) ->
    socket.on @util.client_event('tracker'),      (data) => @user_tracker(socket, data)
    socket.on @util.client_event('tracker_show'), (data) => @show(socket, data)
    socket.on 'disconnect', => @disconnect(socket)

  disconnect:   (socket)       -> @tracker.disconnect(socket)
  user_tracker: (socket, data) -> @tracker.user_tracker(socket, data)
  show:         (socket, data) -> @tracker.show(socket, data)

  join_room:  (socket, room, data) -> @tracker.join_room(socket, room, data)
  leave_room: (socket, room)       -> @tracker.leave_room(socket, room)

  to_string: -> 'ThinkspaceTracker'

module.exports = ThinkspaceTracker
