class ThinkspaceMessages

  constructor: (@platform) ->
    @util     = @platform.util
    @messages = @platform.messages

  # Examples of directly sending messages between users (socket-to-socket) e.g. without using redis.
  # on_connection: (socket) ->
  #   socket.on @util.client_event('room_message'),      (data) => @messages.room_message(socket, data)
  #   socket.on @util.client_event('room_broadcast'),    (data) => @messages.room_broadcast(socket, data)
  #   socket.on @util.client_event('live_room_message'), (data) => @messages.room_message(socket, data)
  #   socket.on @util.client_event('echo'),              (data) => @messages.echo_message(socket, data)

  to_string: -> 'ThinkspaceMessages'

module.exports = ThinkspaceMessages
