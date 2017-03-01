class SocketIORedisClient

  redis: require('redis')

  constructor: (@platform) ->
    @util      = @platform.util
    @messages  = @platform.redis_messages
    @nsio      = @platform.nsio
    @namespace = @platform.namespace
    @init_env_vars()

  init_env_vars: ->
    @url     = @util.env_var('REDIS_URL')
    @util.error 'No SIO_REDIS_URL specified, cannot connect to Redis.' unless @url
    @retries = @util.env_var_int('REDIS_CONNECT_RETRY_ATTEMPTS') or 'none'
    @delay   = @util.env_var_int('REDIS_CONNECT_RETRY_DELAY_SECONDS') or 10

  subscribe: (channel=@namespace, options={}, callback=null) ->
    options.retry_strategy = @retry_strategy  unless options.retry_strategy
    @util.info "redis server subscription '#{@namespace}' -> url: '#{@url}' channel: '#{channel}'"
    client = @redis.createClient(@url)
    client.on 'connect', =>
      @util.info "redis server subscription connected '#{@namespace}' channel: '#{channel}'"
      client.subscribe(channel)
      client.on 'message', (channel, message) => @messages.message(channel, message)
      @platform[callback]() if @util.is_string(callback) and @util.is_function(@platform[callback])
    client.on 'error', (e) =>
      @util.error "Redis server connection failure after #{@retries} retries: '#{@namespace}:#{channel}' -> #{e.message}"

  retry_strategy: (options) =>
    error_code = (options.error or {}).code
    if !error_code or error_code == 'ECONNREFUSED'
      if @retries != 'none' and options.attempt < @retries
        secs  = @delay * options.attempt
        delay = secs * 1000  # convert to milliseconds
        @util.warn "Redis server connection failure.  Retry attempt #{options.attempt} of #{@retries}.  #{secs} seconds until next attempt."
        return delay # retry after
      else
        return new Error 'The server refused the connection.' # end reconnecting on a specific error and flush all commands with a individual error
    if options.times_connected > 3
      undefined # end reconnecting with built in error
    Math.max(options.attempt * 100, 3000) # reconnect after

  to_string: -> 'SocketIORedisClient'

module.exports = SocketIORedisClient
