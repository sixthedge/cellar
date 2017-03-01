import ember from 'ember'

export default ember.Mixin.create

  # ###
  # ### Authorized Room Tracker.
  # ###

  tracker_leave: (options={}) ->
    rooms = @get_options_rooms(options)
    @error("Tracker show leave requires a room.") if ember.isBlank(rooms)
    room_type = options.room_type or 'tracker'
    @leave({rooms, room_type})

  tracker_join: (options={}) ->
    join_options =
      event:                    'tracker'
      room_type:                'tracker'
      source:                   @
      callback:                 'handle_tracker'
      after_authorize_callback: 'emit_tracker'
    ember.merge(join_options, options) if @is_hash(options)
    @error("Tracker requires a room.", join_options)  if ember.isBlank(join_options.room)
    rooms     = ember.makeArray(join_options.room)
    room_type = join_options.room_type
    socket    = @get_socket()
    if @are_rooms_authorized(socket, rooms, room_type)
      @emit_tracker(join_options)
    else
      @join(join_options)

  handle_tracker: -> return

  emit_tracker: (options={}) ->
    event  = options.event or 'tracker'
    socket = @get_socket()
    cevent = @client_event(event)
    href   = window.location.href
    data   = options.data or null
    socket.emit(cevent, {href, data})

  is_tracker_room_authorized: (options={}) ->
    room_type = options.room_type or 'tracker'
    rooms     = @get_options_rooms(options)
    @error("Tracker is authorized requires a room.", options)  if ember.isBlank(rooms)
    socket = @get_socket(options)
    @are_rooms_authorized(socket, rooms, room_type)

  # ###
  # ### Show Tracked Users.
  # ###

  tracker_show: (options={}) ->
    join_options =
      event:                    'tracker_show'
      room_type:                'tracker'
      source:                   @
      callback:                 'handle_tracker_show'
      after_authorize_callback: 'emit_tracker_show'
    ember.merge(join_options, options) if @is_hash(options)
    @error("Tracker show requires a room.", join_options)  if ember.isBlank(join_options.room)
    @join(join_options)

  emit_tracker_show: (options={}) ->
    event = options.event or 'tracker_show'
    rooms = @get_options_rooms(options)
    @error("Tracker show emit requires a room.") if ember.isBlank(rooms)
    room_type = options.room_type or 'tracker'
    socket    = @get_socket()
    cevent    = @client_event(event)
    socket.emit(cevent, {rooms, room_type})

  handle_tracker_show: -> return
