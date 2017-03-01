class SocketIOTimerReload

  constructor: (@platform, @callback) ->
    @util      = @platform.util
    @nsio      = @platform.nsio
    @namespace = @platform.namespace
    @reloaded  = false
    @attempts  = 0
    @retries   = 5
    @init_env_variables()

  init_env_variables: ->
    @url     = @util.env_var('TIMER_RELOAD_URL', @namespace)
    timeout  = @util.env_var('TIMER_RELOAD_TIMEOUT', @namespace)
    @timeout = @util.timeout(timeout)

  process: ->
    return unless @url # if the env url is blank then don't try to reload timers
    @platform.request.post {url: @url, form: {}}, (err, response, body) =>
      return @retry(err) if err
      rc   = response.statusCode
      data = @util.as_json(body)
      if rc != 200
        @util.error "Timer reload failed. [response_code: #{rc}]", data
        return
      unless @util.is_hash(data)
        @util.error "Timer reload response is not a hash.", data
        return
      @success(data)

  retry: (err) ->
    interval = @retry_interval(err)
    if interval
      setTimeout (=>
        @process() unless @reloaded
      ), interval
    else
      @error(err)

  success: (data) ->
    @reloaded = true
    @util.info "TIMER reload successful. [timers reloaded: #{data.timers}]  namespace:", @namespace

  error: (err) -> @util.error "Timer reload server connection failure after #{@retries} retries: ->", err.message

  retry_interval: (err) ->
    return null if @timeout == 'none' or @reloaded
    @attempts += 1
    return null if @attempts > @retries
    interval = @timeout * @attempts * @attempts
    secs     = Math.floor(interval / 1000)
    @util.warn "Timer reload connection failure.  Retry attempt #{@attempts} of #{@retries}.  #{secs} seconds until next attempt."
    interval

  to_string: -> 'SocketIOTimerReload'

module.exports = SocketIOTimerReload
