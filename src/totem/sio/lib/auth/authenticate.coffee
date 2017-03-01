class SocketIOAuthenticate

  constructor: (@platform, @callback) ->
    @util      = @platform.util
    @nsio      = @platform.nsio
    @namespace = @platform.namespace
    @init_env_variables()
    @forbid_connect_until_authorized()

  init_env_variables: ->
    @url     = @util.env_var('AUTHENTICATE_URL', @namespace)
    timeout  = @util.env_var('AUTHENTICATE_TIMEOUT', @namespace)
    @timeout = @util.timeout(timeout)

  forbid_connect_until_authorized: ->
    @nsio.on 'connect', (socket) =>
      return if @util.is_authenticated(socket)
      delete @nsio.connected[socket.id]

  allow_connect: (socket) -> @nsio.connected[socket.id] = socket

  process: (socket, data) ->
    @util.debug '1. Authenticate request sid: ', socket.id
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
          @error(socket, data, json.message || 'not authenticated')
    unless @timeout == 'none'
      setTimeout (=>
        @error(socket, data, 'authenticate timeout')  unless @util.is_authenticated(socket)
      ), @timeout

  success: (socket, data, json) ->
    @util.set_is_authenticated(socket)
    @allow_connect(socket)
    if @util.is_string(@callback) and @util.is_function(@platform[@callback])
      @platform[@callback](socket, data, json)
    else
      @error(socket, 'platform did not have an authenticate callback')

  error: (socket, data, message) ->
    response         = @util.data_response(data)
    response.message = message
    event            = @util.server_event('not_authenticated')
    socket.emit event, response
    @util.debug "authenticate socket disconnect [event: #{event}] [message: #{message}] sid:", socket.id
    @util.disconnect(socket, @platform)

  to_string: -> 'SocketIOAuthenticate'

module.exports = SocketIOAuthenticate
