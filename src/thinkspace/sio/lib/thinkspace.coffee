class ThinkspacePlatform

  constructor: (@server) ->
    @namespace = '/thinkspace'
    @nsio      = @server.io.of(@namespace)
    @request   = @server.request
    @init_modules()
    @init_platform_modules()
    @init_redis()
    @on_connection()

  init_modules: ->
    @util           = new @server.util(@server.debugging)
    @platform_mods  = new @server.platform_modules(@)
    @messages       = new @server.messages(@)
    @timer          = new @server.timer(@)
    @redis_messages = new @server.redis_messages(@)
    @redis_store    = new @server.redis_store(@)
    @rooms          = new @server.rooms(@, room_counts: false)
    @tracker        = new @server.tracker(@)
    @authenticate   = new @server.authenticate(@, 'authenticate_callback')
    @authorize      = new @server.authorize(@, 'authorize_callback')

  init_platform_modules: ->
    @all_modules  = @platform_mods.modules(__dirname)
    @room_modules = ( new mod(@) for mod in @util.room_modules(@all_modules) )
    @conn_modules = ( new mod(@) for mod in @util.on_connection_modules(@all_modules) )

  init_redis: ->
    @redis_client = new @server.redis_client(@)
    @redis_client.subscribe(@namespace, {}, 'init_timers_reload')

  init_timers_reload: ->
    @util.debug 'Reloading Timers for namespace:', @namespace
    @timer.reload()

  on_connection: ->
    @nsio.on 'connection', (socket) =>
      @util.debug '\n', 'on connection sid:', socket.id
      @util.set_not_authenticated(socket)

      socket.on 'disconnect',    => @util.disconnect(socket)
      socket.on 'disconnecting', => @rooms.disconnecting(socket)

      socket.on @util.client_event('authenticate'), (data) => @authenticate.process(socket, data)
      socket.on @util.client_event('authorize'),    (data) => @authorize.process(socket, data)
      socket.on @util.client_event('leave_room'),   (data) => @rooms.leave(socket, data)

      # Call any additional platform modules to add <on 'connection'> events.
      mod.on_connection(socket) for mod in @conn_modules

  # ###
  # ### Callbacks.
  # ###

  # Set any user data returned from the authorize call (e.g. from rails server) on the socket.
  authenticate_callback: (socket, data, json) ->
    @util.set_user_data(socket, json)
    event = @util.server_event('authenticated')
    socket.emit event

  # After all rooms are joined (asyncronously), function 'authorize_complete_callback' will send 'authorized'.
  authorize_callback: (socket, data, json) ->
    @rooms.join(socket, data, @authorize_complete_callback)

  authorize_complete_callback: (socket, data) =>
    response = @util.data_response(data)
    event    = @util.server_event('authorized')
    socket.emit event, response

  to_string: -> 'ThinkspacePlatform'

module.exports = ThinkspacePlatform
