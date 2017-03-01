class SocketIORedisMessages

  constructor: (@platform) ->
    @util  = @platform.util
    @nsio  = @platform.nsio

  # If published via redis, the rooms should already be authorized by the server (e.g. rails server),
  # therefore, just emit the message to the rooms (or all clients if a system message).

  message: (channel, message) ->
    data   = @util.as_json(message)
    action = data.action
    @util.debug '\n', 'REDIS MESSAGE from:', {channel, action}
    switch action
      when 'rooms'             then @emit_to_rooms(data)
      when 'timer'             then @process_timer(data)
      when 'tracker'           then @process_tracker(data)
      when 'system_message'    then @emit_system_message(data)
      else
        @util.error "Unknown redis message action: ", {action, data}

  # Emit to clients in specific rooms.
  emit_to_rooms: (data) ->
    @util.debug '\n', "REDIS MESSAGE (from Rails server) data:\n", data
    rooms = @util.data_rooms(data)
    return unless rooms
    message = @util.data_return_message(data)
    for room in rooms
      event        = @util.data_room_room_event(room, data)
      message.room = room
      @util.debug '\n', @util.bold_line('REDIS MESSAGE EMIT', 'blue') + " event: #{event}; message:\n", message
      @nsio.in(room).emit(event, message)

  # Emit to all clients.
  emit_system_message: (data) ->
    event   = @util.server_event('system_message')
    message = data.message
    @util.debug '\n', "REDIS SYSTEM MESSAGE emit('#{event}') ->", {message, data}
    @nsio.emit(event, message)

  # Process data as a timer.
  process_timer: (data) ->
    unless @platform.timer
      @util.error "Redis timer request but platform does not support a timer.", {data}
      return
    @platform.timer.process(data)

  # Process data as a tracker.
  process_tracker: (data) ->
    unless @platform.tracker
      @util.error "Redis tracker request but platform does not support a tracker.", {data}
      return
    @platform.tracker.process(data)

  to_string: -> 'SocketIORedisMessages'

module.exports = SocketIORedisMessages
