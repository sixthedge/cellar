class SocketIOTimerCountup

  constructor: (@timer) ->
    @util    = @timer.util
    @helpers = @timer.helpers
    @type    = 'countup'

  cancel: -> clearTimeout(@current_timer)  if @current_timer

  create_timeout: ->
    @current_timer = setTimeout (=>
      @emit = @interval_emit()
      @debug()
      @timer.emit(@)
      unless @final
        @setup_timeout()
        @create_timeout()
    ), @timeout

  process: ->
    @unit     = @helpers.data_unit(@data)
    @inc      = @helpers.data_interval(@data)
    @unit_ms  = @helpers.data_milliseconds(@data)
    @end_at   = @helpers.data_end_at(@data)
    @start_at = @helpers.data_start_at(@data)
    @message  = @helpers.data_message(@data)
    unless @valid_and_values_set()
      @timer.remove(@)
      return
    @util.debug "TIMER countup added. id:", @id
    @final   = false
    @n       = 1
    @running = 0
    if @start_at
      @timeout        = @helpers.timeout_value(@start_at)
      @total_timeout -= @timeout
      @set_number_of_timers()
      @set_units()
      @create_timeout()
    else
      @first_emit()
      @setup_timeout()
      @create_timeout()

  first_emit: ->
    @timeout = 0
    @set_units()
    @emit = @interval_emit()
    @debug()
    @timer.emit(@)

  setup_timeout: ->
    @n       += 1
    @running += @inc
    @timeout  = if @running > @total_timeout then (@running - @total_timeout) else @inc
    @set_units()
    @set_final()

  set_final: ->
    @final = true if @running >= @total_timeout
    @final = true if @n > @number_of_timers

  interval_emit: ->
    label = if @units == 1 then @unit else (@unit + 's')
    {@units, label, @n, of: @number_of_timers, @message}

  set_total_timeout:    -> @total_timeout    = @helpers.timeout_value(@end_at)
  set_units:            -> @units            = Math.ceil(@running / @unit_ms)
  set_number_of_timers: -> @number_of_timers = Math.ceil(@total_timeout / @inc) + 1

  valid_and_values_set: ->
    unless @end_at
      @util.warn "TIMER #{@type} end_at is blank.", {@id, @cid, @data}
      return false
    if @start_at and @start_at > @end_at
      @util.error "TIMER #{@type} start at '#{@start_at}' greater than end_at '#{@end_at}'.", {@id, @cid, @data}
      return false
    @set_total_timeout()
    unless @total_timeout and @total_timeout > 0
      @util.warn "TIMER #{@type} in the past. Not running timer.", {@id}
      return false
    @set_number_of_timers()
    if @max and @number_of_timers > @max
      @util.error "TIMER #{@type} has over '#{@max}' timers for id '#{@id}'.  Would have created '#{@number_of_timers}'.", {@id, @cid, @data}
      return false
    true

  debug: -> @util.debugging and @helpers.debug(@)

  to_string: -> 'SocketIOTimerCountup'

module.exports = SocketIOTimerCountup
