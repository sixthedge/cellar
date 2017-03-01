import ember       from 'ember'
import totem_error from 'totem/error'

# An instance of TotemTimer can contain a single timer or multiple timers.
# When containing multiple timers, they can be restarted|cancelled as a unit.

# Timer options (single hash or an array of hashes) containing:
#   source:   [object]   (required) source object with the 'method'
#   method:   [string]   (required) method name called on the 'source'
#   interval: [number]   (required) interval in milliseconds before calling 'source[method]'
#   args:     [any-type] (optional) default null; args passed to method after interval e.g. source[method](args)
#
# Examples:
#  @mytimer = new totem_timer source: @, method: 'my_timer_method', interval: 2000, args: {some: value}
#  @mytimer.start()
#  my_timer_method: (args) ->
#    # do something here
#    # => depending on functionality then could cancel or restart e.g. @mytimer.cancel() -or- @mytimer.restart()
#  
#  @mytimer = new totem_timer [
#    {source: @, method: 'my_timer_method1', interval: 2000,  args: {some: value}}  #=> 2 seconds
#    {source: @, method: 'my_timer_method1', interval: 5000,  args: {some: value}}  #=> 5 seconds
#    {source: @, method: 'my_timer_method2', interval: 10000, args: {some: value}}  #=> 10 seconds
#  ]
#  @mytimer.start()
# 
# TotemTimer has two convience class methods (take the same options as above):
#    new:   create a new TotemTimer 
#    start: create a new TotemTimer and start the timers
# Examples:
#  mytimer1 = totem_timer.new   source: @, method: 'my_timer_method1', interval: 2000
#  mytimer1.start()  #=> required to start the timer(s)
#  mytimer2 = totem_timer.start source: @, method: 'my_timer_method1', interval: 2000  #=> auto-start timer(s) e.g. do not need mytimer.start()

class TotemTimerRunLater
  constructor: (@tt, @config) -> @timer = null
  start:  -> @timer = ember.run.later(@, 'this_timer', @config.interval)
  cancel: -> ember.run.cancel(@timer)  if @timer
  this_timer: ->
    if @tt.is_active(@config.source)
      @config.source[@config.method](@config.args)
    else
      @tt.remove(@)

class TotemTimer

  @new:   (options) -> new TotemTimer(options)
  @start: (options) -> TotemTimer.new(options).start()

  constructor: (@options) ->
    @error "Options must be a hash or array of hashes.", @options  unless (@is_hash(@options) or ember.isArray(@options))
    @validate_and_set_timer_configs()
    @timers = []

  validate_and_set_timer_configs: ->
    @configs = []
    for opt in ember.makeArray(@options)
      source   = opt.source
      method   = opt.method
      interval = opt.interval
      args     = opt.args or null
      @error "Invalid 'options.source'.  Must be an object.", opt                  unless @is_hash(source)
      @error "Invalid 'options.method'.  Must be a string.",  opt                  unless @is_string(method)
      @error "Invalid 'options.interval'.  Must be a number greater than 0.", opt  unless @is_number(interval)
      @error "Method '#{method}' is not a function on the source.",  opt           unless @is_function(source, method)
      @configs.push {source, method, interval, args}

  remove: (timer) -> @timers = @timers.without(timer)

  reset: ->
    @cancel()
    @start()

  start: ->
    for config in @configs
      timer = new TotemTimerRunLater(@, config)
      timer.start()
      @timers.push timer
    return @

  cancel: ->
    for timer in @timers
      timer.cancel()
      timer = null
    @timers = []

  is_number:   (num)         -> "#{num}".match(/^\d+$/)
  is_string:   (str)         -> str and typeof(str) == 'string'
  is_hash:     (obj)         -> @is_object(obj) and not ember.isArray(obj)
  is_object:   (obj)         -> obj and typeof(obj) == 'object'
  is_function: (obj, method) -> @is_object(obj) and typeof(obj[method]) == 'function'

  is_active:   (obj) -> not @is_inactive(obj)
  is_inactive: (obj) ->
    return true unless obj
    return true unless @is_hash(obj)
    obj.isDestroyed or obj.isDestroying

  error: (args...) ->
    message = args.shift() or ''
    console.error message, args if ember.isPresent(args)
    totem_error.throw @, message

  toString: -> 'TotemTimer'

export default TotemTimer
