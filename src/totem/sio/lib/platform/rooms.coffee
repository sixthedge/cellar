class SocketIORooms

  constructor: (@platform, options={}) ->
    @util        = @platform.util
    @redis_store = @platform.redis_store
    @room_counts = options.room_counts or false

  disconnecting: (socket) ->
    if @is_room_counts()
      rooms = @get_socket_rooms(socket)
      @room_count_leave(socket, rooms)

  join: (socket, data, complete_callback=null) ->
    return if @util.is_disconnected(socket)
    return unless @util.can_access(socket)
    rooms = @util.data_rooms(data)
    return complete_callback(socket, data)  if @util.is_array_blank(rooms)
    room_count = 0
    for room in rooms
      callback = if (room_count += 1) >= rooms.length then complete_callback else null
      if @util.in_room(socket, room)
        @join_callback(socket, room, data, callback)
      else
        @room_count_join(socket, [room])
        if @util.debugging
          types = @util.bold_line(@util.data_room_types(data) or 'none', 'cyan')
          event = @util.bold_line(@util.data_room_event(data) or 'none', 'cyan')
          msg   = @util.bold_line('JOIN room', 'cyan') + " #{room}; room_type: " + types + '; room_event: ' + event + '; sid:'
          @util.debug '\n', msg, socket.id
        socket.join(room, => @join_callback(socket, room, data, callback))  # must use a join callback, otherwise, won't be in socket.rooms for 'room_type'

  join_callback: (socket, room, data, complete_callback) ->
    complete_callback(socket, data)  if complete_callback
    @call_room_types(socket, room, data, 'join_room')

  leave: (socket, data) ->
    rooms = @util.data_rooms(data)
    return unless rooms
    room_count = 0
    @room_count_leave(socket, rooms)
    for room in rooms
      room_count += 1
      if @can_access_room(socket, room)
        process = if room_count >= rooms.length then true else false
        if @util.debugging
          types = @util.bold_line(@util.data_room_types(data) or 'none', 'cyan')
          event = @util.bold_line(@util.data_room_event(data) or 'none', 'cyan')
          msg   = @util.bold_line('LEAVE room', 'cyan') + " #{room}; room_type: " + types + '; room_event: ' + event + '; sid:'
          @util.debug '\n', msg, socket.id
        socket.leave(room, => @leave_callback(socket, rooms, data, process))
      else
        @leave_callback(socket, rooms, data, true)

  leave_callback: (socket, rooms, data, process) ->
    return unless process  # need to wait until all room 'leaves' are complete before calling modules
    @call_room_types(socket, room, data, 'leave_room')  for room in rooms

  call_room_types: (socket, room, data, method) ->
    types = @util.data_room_types(data)
    mods  = @platform.room_modules or []
    return if @util.is_array_blank(mods)
    return if @util.is_array_blank(types)
    for type in types
      for mod in mods
        if type == mod.room_type
          @util.debug "CALL #{mod.to_string()}.#{method}('#{room}'); room type: '#{type}' sid: '#{socket.id}'" if @util.debugging
          mod[method](socket, room, data)  if @util.is_function(mod[method])

  can_access_room: (socket, room) -> @util.can_access(socket) and ( @util.in_room(socket, room) or @util.is_superuser(socket) )

  room_count_join:  (socket, rooms) -> @redis_store.join_rooms(socket, rooms)  if @is_room_counts()
  room_count_leave: (socket, rooms) -> @redis_store.leave_rooms(socket, rooms) if @is_room_counts()

  # ###
  # ### Helpers.
  # ###

  is_room_counts: -> @redis_store and @room_counts

  get_users_in_room: (room) ->
    room_sockets = @get_room_sockets(room)
    sockets      = @get_sockets()
    users        = []
    for id, tf of room_sockets
      socket = sockets[id]
      if socket
        if socket.tracker
          user = socket.tracker.get_data()
          user = user.user or {}
        else
          user = @util.get_user_data(socket)
        users.push({user, socket})
    users

  get_sockets: -> @platform.nsio.sockets

  get_room_sockets: (room) ->
    ns_room = @platform.nsio.adapter.rooms[room] or {}
    ns_room.sockets or {}

  get_room_names: ->
    ns       = @platform.namespace
    ns_rooms = @platform.nsio.adapter.rooms
    rooms    = []
    regex    = new RegExp("^#{ns}#")
    for room, hash of ns_rooms
      rooms.push(room) unless room.match(regex)
    rooms

  get_socket_rooms: (socket) ->
    rooms = []
    for room in @util.get_room_names(socket)
      rooms.push(room) if @util.in_room(socket, room) and room != socket.id
    rooms

  print_users_in_room: (room) ->
    users = @get_users_in_room(room)
    @util.blank_line()
    @util.debug "Users in room #{room}:"
    count = 0
    for user in users
      @util.debug "   #{count += 1}. #{user.full_name}"
    @util.blank_line()

  to_string: -> 'SocketIORooms'

module.exports = SocketIORooms
