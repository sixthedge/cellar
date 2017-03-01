class SocketIOTrackerUser

  constructor: (@tracker, @socket) ->
    @debug_color = @tracker.debug_color
    @util        = @tracker.util
    @user_data   = {}
    @user_rooms  = {}
    @auth_user   = null
    @data_user   = null

  get_data: -> @user_data.user = @get_user(); @user_data

  get_rooms: -> @util.hash_keys(@user_rooms)

  in_room: (room) -> @util.is_connected(@socket) and @user_rooms[room]

  track: (rooms, data) ->
    @user_rooms[room]    = true for room in @util.make_array(rooms) 
    @user_data.date1     = new Date() unless @user_data.date1
    @user_data.prev_href = @user_data.href or null
    @user_data.prev_date = @user_data.date or null
    @user_data.data      = data.data or {}
    @user_data.href      = data.href
    @user_data.date      = new Date()
    @data_user           = data.user

  untrack: (rooms) ->
    delete(@user_rooms[room]) for room in @util.make_array(rooms)
    @user_data.date1     = new Date() unless @user_data.date1
    @user_data.prev_href = @user_data.href or null
    @user_data.prev_date = @user_data.date or null
    @user_data.data      = data.data or {}
    @user_data.href      = null
    @user_data.date      = new Date()

  # ###
  # ### Helpers.
  # ###

  get_user: ->
    @set_authenticated_user()
    @auth_user or @data_user or @user_data.user or null

  set_authenticated_user: ->
    return if @auth_user and @auth_user.id
    @auth_user = null
    return unless @util.is_authenticated(@socket)
    user = @util.get_user_data(@socket)
    return unless user.id
    @auth_user = user

  debug: ->
    return 'not debugging' unless @util.debugging
    sid        = @socket.id
    user_data  = @get_data()
    first_name = (user_data.user or {}).first_name
    last_name  = (user_data.user or {}).last_name
    msg        = @util.bold_line("USER TRACKER for #{first_name} #{last_name} sid: #{sid}\n", @debug_color)
    @util.debug msg, {user_data, @user_rooms, @auth_user, @data_user}

  to_string: -> 'SocketIOTrackerUser'

module.exports = SocketIOTrackerUser
