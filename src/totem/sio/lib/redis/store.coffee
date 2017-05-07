class SocketIORedisStore

  redis: require('redis')

  constructor: (@platform) ->
    @util      = @platform.util
    @namespace = @platform.namespace
    @client    = null
    @init_env_vars()
    @set_client()

  init_env_vars: ->
    @url = @util.env_var('REDIS_URL')
    @util.error 'No store SIO_REDIS_URL specified, cannot connect to Redis.' unless @url
    @retries = @util.env_var_int('REDIS_CONNECT_RETRY_ATTEMPTS') or 'none'
    @delay   = @util.env_var_int('REDIS_CONNECT_RETRY_DELAY_SECONDS') or 10

  set_client: (options={}, callback=null) ->
    options.retry_strategy = @retry_strategy  unless options.retry_strategy
    @util.info "redis server store '#{@namespace}' -> url: '#{@url}'"
    @client = @redis.createClient(@url)
    @client.on 'connect', =>
      @clear()
      @util.info "redis server store connected '#{@namespace}'"
      @platform[callback]() if @util.is_string(callback) and @util.is_function(@platform[callback])
    @client.on 'error', (e) =>
      @util.error "Redis server connection failure after #{@retries} retries: '#{@namespace}' -> #{e.message}"

  retry_strategy: (options) =>
    error_code = (options.error or {}).code
    if !error_code or error_code == 'ECONNREFUSED'
      if @retries != 'none' and options.attempt < @retries
        secs  = @delay * options.attempt
        delay = secs * 1000  # convert to milliseconds
        @util.warn "Redis server store connection failure.  Retry attempt #{options.attempt} of #{@retries}.  #{secs} seconds until next attempt."
        return delay # retry after
      else
        return new Error 'The store server refused the connection.' # end reconnecting on a specific error and flush all commands with a individual error
    if options.times_connected > 3
      undefined # end reconnecting with built in error
    Math.max(options.attempt * 100, 3000) # reconnect after

  clear: ->
    @clear_room_counts()

  # ###
  # ### Room Counts.
  # ###

  clear_room_counts: -> @client.del @room_count_key()

  join_rooms:  (socket, rooms) -> @increment_room_counts(socket, rooms, +1)
  leave_rooms: (socket, rooms) -> @increment_room_counts(socket, rooms, -1)

  increment_room_counts: (socket, rooms, n=0) ->
    key = @room_count_key()
    @redis_hash_increment(key, room, n, 'ROOM COUNT') for room in rooms

  room_count_key: -> @redis_room_counts_key ?= "#{@platform.namespace}/room_counts"

  # ###
  # ### Redis Commands.
  # ###

  redis_hash_increment: (key, field, inc, text='') ->
    return unless @client
    @client.hincrby(key, field, inc, (err, val) => @debug_redis_increment(key, field, inc, val, text))

  debug_redis_increment: (key, field, inc, val, text='') ->
    return unless @util.debugging
    ctext  = @util.bold_line(text, 'blue')
    cfield = @util.bold_line(field, 'blue')
    cval   = @util.color_line("#{val}", 'green')
    @util.debug "#{ctext} #{cval} [#{cfield}] - was incremented by: #{inc}"

  to_string: -> 'SocketIORedisStore'

module.exports = SocketIORedisStore
