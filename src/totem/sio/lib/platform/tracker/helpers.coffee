class SocketIOTrackerHelpers

  user_mod: require('./user')

  constructor: (@tracker) ->
    @util     = @tracker.util
    @rooms    = @tracker.rooms

  get_user_tracker: (socket)    -> (socket.tracker ?= new @user_mod(@tracker, socket))
  has_user_tracker: (socket)    -> socket and @util.is_connected(socket) and socket.tracker
  delete_user_tracker: (socket) -> socket and delete(socket.tracker)

  get_all_user_values: (socket) ->
    sockets = @get_sockets()
    value   = []
    for sid, user_socket of sockets
      if @has_user_tracker(user_socket)
        user = @get_user_tracker(user_socket)
        user.debug()
        value.push user.get_data()
    value

  get_room_user_values: (socket, room) ->
    sockets   = @get_sockets()
    room_sids = @get_room_socket_sids(room)
    value     = []
    for sid, tf of room_sids
      if tf and sid != socket.id
        user_socket = sockets[sid]
        if @has_user_tracker(user_socket)
          user = @get_user_tracker(user_socket)
          value.push user.get_data() if user.in_room(room)
    value

  get_socket_by_sid: (sid) -> @get_sockets()[sid]

  get_sockets: -> @rooms.get_sockets()

  get_room_socket_sids: (room) -> @rooms.get_room_sockets(room)

  to_string: -> 'SocketIOTrackerHelpers'

module.exports = SocketIOTrackerHelpers
