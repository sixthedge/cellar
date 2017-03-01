import ember from 'ember'

class TotemError
  toString:    -> 'totem_error'

  constructor: (options={}) ->
    @is_totem_error = true
    @is_handled     = false
    @is_api_error   = options.api or false
    @stack          = options.stack
    @message        = options.message

  # Allow routes and controllers to call: @totem_error.throw(@, message, options).
  # When the source (e.g. @) is passed and has a toString function, will prefix
  # the error message with the toString value.
  throw: (source=null, message=null, options=null) ->
    if typeof(source) == 'string'  # did not pass a source object, so shift arguments
      options = message
      message = source
      source  = null
    # Generate message from arguments.
    message ?= ''
    message  = "#{source.toString()}: #{message}" if source and source.toString
    message += "[#{JSON.stringify(options)}] "    if options
    options = {}  unless options and typeof(options) == 'object'
    # Get stack track and throw error.
    ember_error     = new ember.Error()
    options.message = message
    options.stack   = ember_error.stack
    # If the ember application is not ready (e.g. an error raised in an initializer)
    # throw a javascript Error instead of a TotemError.  Otherwise get 'uncaught exception: totem_error'.
    if ember.onerror
      throw new TotemError(options)
    else
      message += "\n#{options.stack}"  if options.stack
      throw new Error message

  # Class method so if "import from 'totem/error'" can call totem_error.throw(@, message, options).
  @throw: (source=null, message=null, options=null) -> totem_error.throw(source, message, options)

# Create single instance for the @throw class method.
totem_error = new TotemError

export default TotemError
