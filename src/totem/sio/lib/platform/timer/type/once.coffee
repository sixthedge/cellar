class SocketIOTimerOnce

  constructor: (@timer) ->
    @util          = @timer.util
    @helpers       = @timer.helpers
    @current_timer = null
    @final         = true
    @type          = 'once'

  process: ->
    @end_at  = @helpers.data_end_at(@data)
    @timeout = @helpers.timeout_value(@end_at)
    return unless @has_timeout()
    @util.debug "TIMER once added. id:", @id
    @create_timeout()

  cancel: -> clearTimeout(@current_timer)  if @current_timer

  create_timeout: ->
    @current_timer = setTimeout (=>
      @debug()
      @timer.emit(@)
    ), @timeout

  has_timeout: ->
    return true if @timeout and @timeout > 0
    @util.warn "TIMER #{@type} in the past. Not running timer.", {@id}
    @timer.remove(@)
    false

  debug: -> @util.debugging and @helpers.debug(@)

  to_string: -> 'SocketIOTimerOnce'

module.exports = SocketIOTimerOnce
