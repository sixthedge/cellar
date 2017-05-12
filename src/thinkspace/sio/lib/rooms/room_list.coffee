class ThinkspaceRoomList

  constructor: (@platform) ->
    @util        = @platform.util
    @rooms       = @platform.rooms
    @redis_store = @platform.redis_store

  on_connection: (socket) ->
    socket.on @util.client_event('room_list'), (data)         => @emit_room_list(socket, data)
    socket.on @util.client_event('room_counts'), (data)       => @emit_room_counts(socket, data)
    socket.on @util.client_event('room_counts_reset'), (data) => @room_counts_reset(socket, data)

  emit_room_list: (socket, data={}) ->
    unless @util.is_superuser(socket)
      @util.error "Unauthorized room list request for non-superuser.", @util.get_user_date(socket)
      return
    rooms      = @rooms.get_room_names()
    room_users = {}
    for room in rooms
      users = @rooms.get_users_in_room(room)
      for hash in users
        if @util.is_hash(hash)
          room_user = hash.user
          if @util.is_hash_present(room_user)
            user        = {id, username, first_name, last_name, email} = room_user
            user_socket = hash.socket
            user.sid    = user_socket.id
            user.href   = (user_socket.tracker.user_data or {}).href if user_socket and user_socket.tracker
            room_users[room] ?= []
            room_users[room].push(user)
    sevent = @util.server_event('room_list')
    socket.emit(sevent, room_users)

  emit_room_counts: (socket, data={}) ->
    unless @util.is_superuser(socket)
      @util.error "Unauthorized room count request for non-superuser.", @util.get_user_date(socket)
      return
    sevent = @util.server_event('room_counts')
    unless @rooms.is_room_counts()
      socket.emit(sevent, {})
      return
    key = @redis_store.room_count_key()
    @redis_store.client.hgetall(key, (err, hash) => socket.emit(sevent, hash))

  room_counts_reset: (socket, data={}) ->
    unless @util.is_superuser(socket)
      @util.error "Unauthorized room count reset request for non-superuser.", @util.get_user_date(socket)
      return
    return unless @util.is_hash(data)
    unless @rooms.is_room_counts()
      @emit_room_counts(socket)
      return
    key   = @redis_store.room_count_key()
    room  = data.room
    count = data.count
    if room == '*'
      @redis_store.client.del(key, => @emit_room_counts(socket))
      return
    @redis_store.client.hset(key, room, count, (err, hash) => @emit_room_counts(socket))

  to_string: -> 'ThinkspaceRoomList'

module.exports = ThinkspaceRoomList
