class SocketIOAuthorize

  constructor: (@platform, @callback) ->
    @util      = @platform.util
    @namespace = @platform.namespace
    @request   = @platform.request
    @async     = @platform.async
    @init_env_variables()

  init_env_variables: ->
    @url     = @util.env_var('AUTHORIZE_URL', @namespace)
    @timeout = @util.env_var_int('AUTHORIZE_TIMEOUT', @namespace) or 3000
    @retries = @util.env_var_int('AUTHORIZE_RETRIES', @namespace) or 1

  process: (socket, data) ->
    @util.set_not_authorized(socket)
    return unless @util.is_authenticated(socket)
    @util.debug '2a. Authorize request sid: ', socket.id, 'auth_key:', data.auth_key, 'rooms:', data.rooms, 'room_type:', (data.room_type or 'none')
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
    util.debug '2b. Authorize request sid: ', args.socket.id, 'retry:', args.retry
    request.post opts, (err, response, body) =>
      result = {args, response, body}
      return cb(err, result) if err
      cb(null, result)

  success: (socket, data, json) ->
    @util.set_is_authorized(socket)
    @util.debug '2c. Authorize success sid: ', socket.id, 'auth_key:', data.auth_key, 'rooms:', data.rooms, 'room_type:', (data.room_type or 'none')
    if @util.is_string(@callback) and @util.is_function(@platform[@callback])
      @platform[@callback](socket, data, json)
    else
      @error(socket, 'platform did not have an authorize callback')

  error: (socket, data, message) ->
    response         = @util.data_response(data)
    response.message = message
    event            = @util.server_event('not_authorized')
    socket.emit event, response
    @util.error "2c. Authorize socket disconnect [event: #{event}] [message: #{message}] sid:", socket.id
    @util.disconnect(socket, @platform)

  to_string: -> 'SocketIOAuthorize'

module.exports = SocketIOAuthorize
