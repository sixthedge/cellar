class SocketIOAuthenticate

  constructor: (@platform, @callback) ->
    @util      = @platform.util
    @nsio      = @platform.nsio
    @namespace = @platform.namespace
    @request   = @platform.request
    @async     = @platform.async
    @init_env_variables()
    @forbid_connect_until_authorized()

  init_env_variables: ->
    @url     = @util.env_var('AUTHENTICATE_URL', @namespace)
    @timeout = @util.env_var_int('AUTHENTICATE_TIMEOUT', @namespace) or 3000
    @retries = @util.env_var_int('AUTHENTICATE_RETRIES', @namespace) or 1

  forbid_connect_until_authorized: ->
    @nsio.on 'connect', (socket) =>
      return if @util.is_authenticated(socket)
      delete @nsio.connected[socket.id]

  allow_connect: (socket) -> @nsio.connected[socket.id] = socket

  process: (socket, data) ->
    @util.debug '1a. Authenticate request sid: ', socket.id
    [auth_data, auth_header] = @util.get_auth_data_and_header(data)
    unless (auth_data and auth_header)
      @util.error "Auth data and/or auth header is blank.", {auth_data, auth_header}
      return
    args =
      socket: socket
      data:   data
      retry:  0
      request_opts:
        url:     @url
        headers: auth_header
        form:    auth_data
        timeout: @timeout
    @send_auth_request(args)

  send_auth_request: (args) ->
    send = @async.apply @send_auth_request_to_server, @request, @util, args
    @async.retry {times: @retries, interval: @timeout}, send, (err, result) =>
      args   = result.args or {}
      socket = args.socket
      data   = args.data
      if err
        @error(socket, data, err)
      else
        json = @util.as_json(result.body)
        if json.can == true
          @success(socket, data, json)
        else
          @error(socket, data, json.message || 'not authenticated')

  send_auth_request_to_server: (request, util, args, cb) ->
    args.retry += 1
    opts        = args.request_opts
    util.debug '1b. Authenticate request sid: ', args.socket.id, 'retry:', args.retry
    request.post opts, (err, response, body) =>
      result = {args, response, body}
      return cb(err, result) if err
      cb(null, result)

  success: (socket, data, json) ->
    @util.set_is_authenticated(socket)
    @allow_connect(socket)
    @util.debug '1c. Authenticate success sid: ', socket.id
    if @util.is_string(@callback) and @util.is_function(@platform[@callback])
      @platform[@callback](socket, data, json)
    else
      @error(socket, 'platform did not have an authenticate callback')

  error: (socket, data, message) ->
    response         = @util.data_response(data)
    response.message = message
    event            = @util.server_event('not_authenticated')
    socket.emit event, response
    @util.error "1c. Authenticate socket disconnect [event: #{event}] [message: #{message}] sid:", socket.id
    @util.disconnect(socket, @platform)

  to_string: -> 'SocketIOAuthenticate'

module.exports = SocketIOAuthenticate
