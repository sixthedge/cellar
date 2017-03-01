import ember  from 'ember'

class ModelValidation

  message_prop: 'validation_model_messages'

  handle: (api, options) ->
    console.warn 'options', options
    target = options.validation or options.source
    api.throw_error('The model had validation errors but no message target [validation|source] was provided.', options)  unless target

    # If "options.validation_prop: 'some-prop-name'" or "options.validation_prop: true"
    # then set the property to an array of validation error messages.
    if prop = options.validation_prop
      prop = @message_prop  if prop == true  # allow 'options.validation_prop: true'
      @set_errors_on_target_property(api, target, prop, options)
      return

    if @has_validation_mixin(target)
      # To view messages, use the 'modelErrors' validator for the property.
      @add_to_validation_mixin_errors(target, options)
    else
      # If the target does not have the validation mixin, assume setting
      # the messages on the default property name 'validation_model_messages'.
      @set_errors_on_target_property(api, target, @message_prop, options)

  add_to_validation_mixin_errors: (target, options) ->
    errors = @get_errors_from_options(options)
    target.add_validation_model_errors(errors)

  set_errors_on_target_property: (api, target, prop, options) ->
    api.throw_error("The model validation target does not have the property [#{prop}].", options)  if typeof(target.get prop) == 'undefined'
    messages = []
    for own key, msg_array of @get_errors_from_options(options)
      messages.push @get_message(key, msg, options) for msg in msg_array
    target.set prop, messages

  get_errors_from_options: (options) ->
    error = options.error or {}
    if error.responseJSON
      errors = error.responseJSON.errors    # done via direct ajax call (e.g. not through ActiveModelAdapter)
    else
      errors = error.errors                 # done via ActiveModelAdapter
    errors or {}

  get_message: (key, message, options) -> (options.with_key == false and message) or "#{key} #{message}"

  has_validation_mixin: (target) -> target.get('is_validation_mixin_included')

export default new ModelValidation
