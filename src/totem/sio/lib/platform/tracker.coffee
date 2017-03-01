class SocketIOTracker

  trackers_mod: require('./tracker/trackers')
  helpers_mod:  require('./tracker/helpers')

  constructor: (@platform) ->
    @debug_color = 'light_yellow'
    @util        = @platform.util
    @rooms       = @platform.rooms
    @helpers     = new @helpers_mod(@)
    @trackers    = new @trackers_mod(@)

  # ###
  # ### Redis PubSub Event for an Authorized Tracker.
  # ###

  # Process Redis client pubsub with action = 'tracker'.
  # Add the user as a tracker of rooms (since authorized by the server).
  process: (data) -> @trackers.process(data)

  # ###
  # ### Events.
  # ###

  join_room:  (socket, room, data) ->
    @rooms.room_count_join(socket, [room])
    data.room = room # set the room in the data hash
    @user_tracker(socket, data)

  leave_room: (socket, room) ->
    @rooms.room_count_leave(socket, [room])
    @trackers.delete_room(socket, room)  # delete this room if a tracker and tracking this room
    @trackers.show_update(room)          # update the trackers that this user has left the room

  disconnect: (socket) ->
    rooms = @get_user_rooms(socket)      # get the rooms the user is being tracked
    @helpers.delete_user_tracker(socket) # delete this socket's user tracker
    @trackers.delete(socket)             # if also a tracker, delete them
    @trackers.show_update(rooms)         # update the trackers that this user has left the rooms

  user_tracker: (socket, data) ->
    rooms = @util.data_rooms(data)       # the rooms to track the user
    user  = @get_user_tracker(socket)    # this sockets user tracker
    user.track(rooms, data)              # track the rooms for this user
    @trackers.show_update(rooms)         # update the trackers that this user has new tracking data

  show: (socket, data) ->
    rooms     = @util.data_rooms(data)
    room_type = data.room_type
    @trackers.show_emit(socket, rooms, room_type) # emit the rooms' user data to the tracker

  # ###
  # ### Helpers
  # ###

  get_user_tracker: (socket) -> @helpers.get_user_tracker(socket)
  get_user_rooms:   (socket) -> @helpers.get_user_tracker(socket).get_rooms()

  to_string: -> 'SocketIOTracker'

module.exports = SocketIOTracker
