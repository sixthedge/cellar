class SocketIOServer

  request: require('request')
  http:    require('http')
  async:   require('async')

  authenticate:     require('./auth/authenticate')
  authorize:        require('./auth/authorize')
  redis_client:     require('./redis/client')
  redis_messages:   require('./redis/messages')
  redis_store:      require('./redis/store')
  messages:         require('./platform/messages')
  platform_modules: require('./platform/modules')
  rooms:            require('./platform/rooms')
  timer:            require('./platform/timer')
  tracker:          require('./platform/tracker')
  util:             require('./shared/util')

  constructor: ->
    @sutil = new @util()
    @init_env_vars()
    @app = @http.createServer()
    @io  = require('socket.io')(@app)
    # Cloud providers will often not allow a host to be defined here.
    # => Results in EADDRINUSE error.
    if @app_host then @app.listen(@app_port, @app_host) else @app.listen(@app_port)

  init_env_vars: ->
    @debugging       = @sutil.env_var('DEBUGGING') == 'true'
    @sutil.debugging = @debugging # set debugging so below 'env_var' will print on console when true
    @app_port        = @sutil.env_var('APP_PORT')
    @app_host        = @sutil.env_var('APP_HOST')
    @sutil.throw_error(@, "Missing env 'APP_PORT' value") unless @app_port

  to_string: -> 'SocketIOServer'

module.exports = SocketIOServer
