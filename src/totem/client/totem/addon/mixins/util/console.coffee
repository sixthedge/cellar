import ember  from 'ember'
import config from 'totem-config/config'

export default ember.Mixin.create

  console_log:   -> console.log arguments...
  console_info:  -> console.info arguments...
  console_warn:  -> console.warn arguments...
  console_error: -> console.error arguments...

  warn:  (source, args...) -> console.warn @get_log_message(source, args), args...

  error: (source, args...) ->
    message = @get_log_message(source, args)
    console.error message, args...
    throw new ember.Error message

  get_log_message: (source, args) ->
    message = ''
    switch
      when @is_string(source)  then message = source
      when @is_hash(source)
        arg      = if @is_string(args[0]) then args.shift() else null
        message += "#{source.toString()}: " if @is_object_function(source, 'toString')
        message += arg if @is_string(arg)
    message

  get_log_config:        -> (config.logger ?= {})
  get_log_level:         -> @get_log_config().log_level
  set_log_level: (level) -> @get_log_config().log_level = level

  log_debug: -> @get_log_level() == 'debug'
  log_error: -> @get_log_level() == 'error'
  log_warn:  -> @get_log_level() == 'warn'
  log_info:  -> @get_log_level() == 'info'
  log_none:  -> @get_log_level() == 'none'
