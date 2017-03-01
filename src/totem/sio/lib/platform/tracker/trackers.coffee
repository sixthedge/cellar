class SocketIOTrackerTrackers

  constructor: (@tracker) ->
    @util        = @tracker.util
    @helpers     = @tracker.helpers
    @debug_color = @tracker.debug_color
    @trackers    = {}

  # ###
  # ### Create Tracker (from server Redis PubSub data).
  # ###

  process: (data) ->
    rooms     = @util.data_rooms(data)
    value     = data.value or {}
    room_type = value.room_type
    sid       = value.sid
    socket    = @helpers.get_socket_by_sid(sid)
    if @util.is_disconnected(socket)
      @delete(socket)
      return
    tracker             = @get_tracker(socket)
    tracker.rooms[room] = (room_type or 'tracker') for room in @util.make_array(rooms)
    tracker.all_rooms   = value.all_rooms or false
    tracker.socket      = socket
    @trackers[sid]      = tracker
    if @util.debugging
      for_user     = @util.get_user_data(socket)
      redis_data   = data
      tracker_data = {rooms: tracker.rooms, all_rooms: tracker.all_rooms, sid: sid}
      @util.debug @util.bold_line("Redis generated TRACKER:\n", @debug_color), {for_user, redis_data, tracker_data}

  # ###
  # ### Emit Show e.g. to instructors.
  # ###

  # User room change (e.g. join/leave) for rooms.
  show_update: (rooms) ->
    sids = @util.hash_keys(@trackers)
    for sid in sids
      tracker = @get_tracker_by_sid(sid)
      for room in @util.make_array(rooms)
        room_type = tracker.rooms[room]
        socket    = @trackers[sid].socket
        @show_emit(socket, room, room_type)

  # Emit the user room change to the trackers.
  show_emit: (socket, rooms, room_type=null) ->
    is_superuser = @util.is_superuser(socket)
    for room in @util.make_array(rooms)
      if is_superuser and @is_all_rooms(socket)
        value = @helpers.get_all_user_values(socket)
      else
        value = @helpers.get_room_user_values(socket, room)
      event = if room_type then @util.server_event(room, room_type) else @util.server_event(room)
      if @util.debugging
        sid = socket.id
        @util.debug @util.bold_line("TRACKER SHOW EMIT\n", @debug_color), {sid, event}, "\nvalue:", value  
      socket.emit event, {value}

  # ###
  # ### Delete Tracker and Tracker Room.
  # ###

  delete: (socket) -> socket and delete(@trackers[socket.id])

  delete_room: (socket, room) ->
    rooms = @get_rooms(socket)
    delete(rooms[room])

  # ###
  # ### Helpers.
  # ###

  get_tracker_by_sid: (sid) ->
    tracker        = @trackers[sid] or {}
    tracker.rooms ?= {}
    tracker

  get_tracker: (socket) -> (socket and @get_tracker_by_sid(socket.id)) or {}

  get_rooms: (socket) -> @get_tracker(socket).rooms

  is_all_rooms: (socket) -> @get_tracker(socket).all_rooms

  to_string: -> 'SocketIOTrackerTrackers'

module.exports = SocketIOTrackerTrackers
