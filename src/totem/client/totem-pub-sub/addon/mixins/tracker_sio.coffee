import ember from 'ember'

export default ember.Mixin.create

  # ###
  # ### Socketio-only Tracker.
  # ###

  tracker_sio_callback_map: ember.Map.create()

  tracker_sio_leave: (options={}) ->
    rooms = @get_options_rooms(options)
    @error("Tracker show leave requires a room.") if ember.isBlank(rooms)
    event  = 'tracker_sio_leave'
    cevent = @client_event(event)
    socket = @get_non_auth_socket()
    socket.emit(cevent, {rooms})

  tracker_sio_join: (options={}) ->
    rooms = @get_options_rooms(options)
    @error("Tracker SIO requires a room.", options)  if ember.isBlank(rooms)
    connect_options =
      source:   @
      callback: 'after_tracker_sio_connect'
      options:  options
    @get_non_auth_socket(connect_options)

  after_tracker_sio_connect: (socket, options) ->
    options = options.options or {}
    @emit_tracker_sio_join(socket, options)
    if ember.isPresent(options.callback)
      @tracker_sio_callback_map.set(options, socket)
      @call_non_auth_socket_callbacks(@tracker_sio_callback_map)

  emit_tracker_sio_join: (socket, options={}) ->
    event  = 'tracker_sio_join'
    cevent = @client_event(event)
    href   = window.location.href
    rooms  = @get_options_rooms(options)
    user   = @get_tracker_sio_user_data()
    data   = options.data or {}
    socket.emit(cevent, {rooms, user, href, data})

  get_tracker_sio_user_data: ->
    current_user = @current_user()
    return {} unless ember.isPresent(current_user)
    user = 
      id:         current_user.get('id')
      first_name: current_user.get('first_name')
      last_name:  current_user.get('last_name')
      email:      current_user.get('email')
      username:   current_user.get('email')
    user

  # ###
  # ### Show Tracked SIO Users to Trackers e.g. instructors.
  # ###

  tracker_sio_show: (options={}) ->
    rooms = @get_options_rooms(options)
    @error("Tracker show emit requires a room.") if ember.isBlank(rooms)
    event     = options.event or 'tracker_show'
    socket    = options.socket or @get_non_auth_socket()
    room_type = options.room_type or 'tracker'
    cevent    = @client_event(event)
    callback  = options.callback
    source    = options.source
    if ember.isPresent(callback) and ember.isPresent(source)
      for room in rooms
        sevent = @server_event(room, room_type)
        @on(socket, sevent, source, callback)
    socket.emit(cevent, {rooms, room_type})
