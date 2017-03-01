class ThinkspaceRoomUserList

  room_type: 'user_list'

  constructor: (@platform) ->
    @util     = @platform.util
    @messages = @platform.messages
    @rooms    = @platform.rooms
    @nsio     = @platform.nsio

  on_connection: (socket) ->
    # Send the current user list to the room(s) when the client emits a 'user_list' request.
    socket.on @util.client_event('user_list'), (data) =>
      rooms = @util.data_rooms(data)
      return unless rooms
      # TODO: check if can_access_rooms
      @update_user_list(rooms)
    # When socket is disconnected, update the socket's user list room(s).
    socket.on 'disconnect', => @leave_room(socket, room) for room in @get_user_list_rooms(socket)

  join_room: (socket, room, data) ->
    rooms               = (socket.user_list_rooms ?= {})
    rooms[room]         = true unless rooms[room]
    observe_rooms       = (socket.user_list_observe_rooms ?= {})
    observe_rooms[room] = true  if data.room_observer

  leave_room: (socket, room) ->
    rooms = (socket.user_list_rooms or {})
    delete(rooms[room])
    if @is_room_observer(socket, room)
      observers = (socket.user_list_observe_rooms or {})
      delete(observers[room])
    else
      @update_user_list([room])

  update_user_list: (rooms) ->
    for room in rooms
      user_list = @get_room_user_list(room)
      event     = @util.server_event(room) + "/#{@room_type}"
      @util.debug '\n', "USER_LIST emit('#{event}') room: '#{room}' data:", user_list
      @nsio.in(room).emit(event, {user_list})

  get_room_user_list: (room) ->
    users = @rooms.get_users_in_room(room)
    ids   = []
    list  = []
    for hash in users
      socket = hash.socket or {}
      unless @is_room_observer(socket, room)
        user = hash.user or {}
        id   = user.id
        if user.id and not @util.array_contains(ids, id)
          first_name = user.first_name
          last_name  = user.last_name
          list.push({id, first_name, last_name})
          ids.push(id)
    list

  is_room_observer: (socket, room) -> (socket.user_list_observe_rooms or {})[room]

  get_user_list_rooms: (socket) -> Object.keys(socket.user_list_rooms or {})

  to_string: -> 'ThinkspaceRoomUserList'

module.exports = ThinkspaceRoomUserList
