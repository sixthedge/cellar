class SocketIOAuthorize

  constructor: (@platform, @callback) ->
    @util      = @platform.util
    @namespace = @platform.namespace
    @init_env_variables()

  init_env_variables: ->
    @url     = @util.env_var('AUTHORIZE_URL', @namespace)
    timeout  = @util.env_var('AUTHORIZE_TIMEOUT', @namespace)
    @timeout = @util.timeout(timeout)

  process: (socket, data) ->
    @util.set_not_authorized(socket)
    return unless @util.is_authenticated(socket)
    @util.debug '2. Authorize request sid: ', socket.id, 'auth_key:', data.auth_key, 'rooms:', data.rooms, 'room_type:', (data.room_type or 'none')
    [auth_data, auth_header] = @util.get_auth_data_and_header(data)
    unless (auth_data and auth_header)
      @util.error "Auth data and/or auth header is blank.", {auth_data, auth_header}
      return
    @platform.request.post {url: @url, headers: auth_header, form: auth_data}, (err, response, body) =>
      if err
        @error(socket, data, err)
      else
        json = @util.as_json(body)
        if json.can == true
          @success(socket, data, json)
        else
          @error(socket, data, json.message || 'not authorized')
    unless @timeout == 'none'
      setTimeout (=>
        @error(socket, data, 'authorize timeout')  unless @util.is_authorized(socket)
      ), @timeout

  success: (socket, data, json) ->
    @util.set_is_authorized(socket)
    if @util.is_string(@callback) and @util.is_function(@platform[@callback])
      @platform[@callback](socket, data, json)
    else
      @error(socket, 'platform did not have an authorize callback')

  error: (socket, data, message) ->
    response         = @util.data_response(data)
    response.message = message
    event            = @util.server_event('not_authorized')
    socket.emit event, response
    @util.debug "authorize socket disconnect [event: #{event}] [message: #{message}] sid:", socket.id
    @util.disconnect(socket, @platform)

  to_string: -> 'SocketIOAuthorize'

module.exports = SocketIOAuthorize
