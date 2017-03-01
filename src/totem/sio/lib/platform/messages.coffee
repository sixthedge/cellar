class SocketIOMessages

  constructor: (@platform) ->
    @util = @platform.util
    @nsio = @platform.nsio

  echo_message: (socket, data) -> socket.emit @util.server_event('echo'), data

  room_broadcast: (socket, data) ->
    rooms = @util.data_rooms(data)
    return unless rooms
    for room in rooms
      if @util.can_access_room(socket, room)
        event = @util.data_room_room_event(room, data)
        data  = @util.data_return_message(data)
        @util.debug '\n', "ROOM BROADCAST emit('#{event}')", 'data:', data
        socket.broadcast.to(room).emit(event, data)
      else
        @util.warn '\n', "Unauthorized attempt to broadcast to room '#{room}' by user:", @platform.auth.get_user_data(socket), data
        @util.blank_line()

  room_message: (socket, data) ->
    rooms = @util.data_rooms(data)
    return unless rooms
    for room in rooms
      if @util.can_access_room(socket, room)
        event = @util.data_room_room_event(room, data)
        data  = @util.data_return_message(data)
        @util.debug '\n', "ROOM MESSAGE emit('#{event}')", 'data:', data
        @nsio.in(room).emit(event, data)
      else
        @util.warn '\n', "Unauthorized attempt to emit to room '#{room}' by user:", @platform.auth.get_user_data(socket), data
        @util.blank_line()

  to_string: -> 'SocketIOMessages'

module.exports = SocketIOMessages
