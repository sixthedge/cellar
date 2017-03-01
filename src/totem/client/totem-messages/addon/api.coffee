import ember  from 'ember'
import util   from 'totem/util'
import totem_error  from 'totem/error'
import status_codes from 'totem-messages/api_status_codes'
import model_val    from 'totem-messages/model_validation'
import i18n         from 'totem/i18n'
import config       from 'totem-config/config'

class ApiMessages

  # ###
  # ### Main Public Functions.
  # ###

  success: (options={}) ->
    base_options = status_codes.definition('success')
    options      = @merge_options(base_options, options)
    return @return_value(options) unless options.i18n_path # don't queue message if an i18n path isnt provided
    @queue_message(options)
    @process_handler(options)
    @return_value(options)

  failure: (error, options={}) ->
    options.error      = error
    options.error_code = @status_code_from_error(error)
    base_options       = status_codes.definition(options.error_code) or status_codes.definition('failure')
    options            = @merge_options(base_options, options)
    console.warn 'failure', error, options
    @process_callback(options).then =>
      @process_failure(error, options)
    , (e) =>
      # If a callback responds with a promise 'reject' and the reject-error contains 'cancel: true', do not continue to process the failure.
      @process_failure(error, options)  unless e and e.cancel == true

  process_failure: (error, options) ->
    @queue_message(options)
    @process_handler(options)
    @process_model_rollback(options)
    @app_msgs.hide_loading_outlet()  if options.hide_loading
    if options.fatal
      totem_error.throw @, @get_error_message(options), api: true  # not using @throw_error() to prevent queuing the detailed error message
    else
      @log_error(options)
      @return_value(options)

  return_value: (options) -> options.return or options.model or null

  # ###
  # ### Callback.
  # ###

  # Callback Examples (callback only called if the options contains 'allow_callback: true'):
  #   1. @totem_messages.api_failure error, source: @, model: record, callback: @api_failure_callback  #=> all status codes (with allow_callback: true)
  #   2. @totem_messages.api_failure error, source: @, model: record, callback: {unauthorized_access: @api_failure_callback}  #=> only 'unauthorized_access'
  #   3. @totem_messages.api_failure error, source: @, model: record, callback: {423: @api_failure_callback}  #=> only error code 423 (e.g. unauthorized access)
  process_callback: (options) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve() unless options.allow_callback
      callback = options.callback
      return resolve() unless callback
      switch typeof(callback)
        when 'function'
          @call_callback(callback, options).then =>
            resolve()
          , (error) =>
            reject(error)
        when 'object'
          if (handler = options.handler)
            handler_callback = callback[handler]  # first find by name
            unless handler_callback
              if (error_code = options.error_code)
                handler_callback = callback[error_code]  # second (and last) find by error code
            if handler_callback
              @call_callback(handler_callback, options).then =>
                resolve()
              , (error) =>
                reject(error)
            else
              resolve()
        else resolve()

  call_callback: (callback, options) ->
    new ember.RSVP.Promise (resolve, reject) =>
      if (source = options.source)
        response = callback.call(source, options)  # call the callback with the callback's 'this' set to the source
      else
        response = callback(options)
      # If the callback returns a promise, wait for the promise to resolve before continuing (e.g. resolve this function promise).
      if response.then?
        response.then =>
          resolve()
        , (error) =>
          reject(error)
      else
        resolve()

  # ###
  # ### Handlers.
  # ###

  process_handler: (options) ->
    handler = options.handler
    switch handler
      when 'model_validation' then mod = model_val
      else return
    @throw_error("Handler module [#{handler}] is missing.")  unless mod
    @throw_error("Handler module [#{handler}] does not have a [handle] function.")  unless typeof(mod.handle) == 'function'
    mod.handle(@, options)

  # ###
  # ### Model Rollback.
  # ###
  process_model_rollback: (options) ->
    return unless options.model_rollback
    options.model.rollback()  if options.model and typeof(options.model.rollback) == 'function'

  # ###
  # ### Message.
  # ###

  queue_message: (options) ->
    message = @get_options_message(options)
    queue   = options.queue
    return unless queue
    @throw_error("Invalid status code message queue [#{queue}].") unless typeof(@app_msgs[queue]) == 'function'
    @app_msgs[queue](message, options.sticky)

  get_options_message: (options) ->
    if options.allow_user_message
      message = @get_options_user_message(options)
      return message  if message
    i18n.message
      path:         @get_i18n_message_path(options)
      args:         @get_i18n_args(options)
      default_path: 'totem.api.status_codes.default'
      default_args: options.handler

  get_options_user_message: (options) ->
    return options.user_message if options.user_message
    response_json = options.error and options.error.responseJSON
    response_json and response_json.errors and response_json.errors.user_message

  get_i18n_message_path: (options) ->
    prefix = config.messages.i18n_path_prefix
    path   = options.i18n_path
    path   = prefix + path if (ember.isPresent(path) and ember.isPresent(prefix))
    return path if path
    if (matches = options.match_response_text) and (message = options.error.responseText)
      for own key, value of matches
        regex = new RegExp(key, 'i')
        if message.match(regex)
          path = "totem.api.status_codes.#{value}"
          break
    path or "totem.api.status_codes.#{options.handler}"

  get_i18n_args: (options) ->
    return [] unless options.i18n
    i18n_attrs = ember.makeArray(options.i18n)
    args       = []
    for attr in i18n_attrs
      switch attr
        when 'resource'
          args.push @get_model_name(options)
        when 'action'
          args.push @get_action(options)
    args

  get_action: (options) -> options.action or 'find'

  get_model_name: (options) ->
    model = options.model or 'unknown'
    if typeof(model) == 'string'
      type = model
    else
      if ember.isArray(model)
        type = model.get('type').modelName
        type = type.pluralize()
      else
        type = model.constructor.modelName
    type.split('/').pop()

  # ###
  # ### Error Messages.
  # ###

  get_error_message: (options) ->
    message = ''
    if typeof(options.fatal) == 'string' and options.fatal != ''
      @app_msgs.fatal options.fatal
      message += "[fatal: #{options.fatal}] "
    source      = options.source and options.source.toString and options.source.toString()
    status_code = options.error_code or 'unknown'
    handler     = options.handler or 'unknown'
    error       = options.error
    if error
      error_message = options.error_message or error.message or error.responseText or error.statusText
      errors        = error.errors and @stringify(error.errors)
    message        += "[source: #{source}] "  if source
    message        += "[status-code: #{status_code}] [handler-name: #{handler}] "
    message        += "[errors: #{errors}] "  if errors
    message        += "[error-message: #{error_message}] "  if error_message
    message

  # ###
  # ### Helpers.
  # ###

  set_app_msgs: (app_msgs) -> @app_msgs = app_msgs

  # Merge options into base options.
  merge_options: (base_options, options) ->
    merged = {}
    ember.merge(merged, base_options)
    ember.merge(merged, options)
    merged.message_array ?= []
    merged

  # Status code from error object.
  status_code_from_error: (error) ->
    # The ember-data ActiveModelAdapter raises an 'InvalidError' on a '422' (e.g. model validation error).
    error.status = 422 if error and (not error.status) and error.stack and util.starts_with(error.stack, 'InvalidError')
    error and error.status

  # Throw Api Error.
  throw_error: (message, options=null) ->
    @app_msgs.error(message)
    @log_error(options)  if options
    totem_error.throw @, message, api: true

  log_error: (options) -> util.console_error @get_error_message(options), options

  stringify: (object) -> JSON.stringify(object)

  toString: -> 'totem_messages:api'

export default new ApiMessages
