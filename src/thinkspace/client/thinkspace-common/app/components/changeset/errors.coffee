import ember from 'ember'

# Examples to call this component:
#   component '__changeset/errors' changeset=changeset                    #=> for model attributes (e.g. bottom of page)
#   component '__changeset/errors' changeset=changeset attribute='title'  #=> single model attribute; e.g. under input for 'title'

# changeset.get('errors') is an array of hashes:
#   hash.key        = attribute name
#   hash.validation = array of error messages

# If changeset.first_error is true (default false) only the first error will be shown.
# Use changeset.first_error_on() and changeset.first_error_off().

export default ember.Component.extend
  tagName: ''

  tvo: ember.inject.service()

  errors_visible: ember.computed.or 'tvo.show_errors', 'changeset.show_errors', 'show_errors'

  input_id:    null
  error_class: null

  messages: ember.computed 'changeset.errors', ->
    return null if ember.isBlank(@changeset)
    errors   = @changeset.get('errors') or []
    errors   = [errors.findBy('key', @attribute)].compact() if ember.isPresent(@attribute)
    messages = @collect_validation_messages(errors)
    messages = [messages.get('firstObject')] if @changeset.first_error and ember.isPresent(messages)
    @update_error_class(messages) if ember.isPresent(@input_id) and ember.isPresent(@error_class)
    messages

  collect_validation_messages: (errors) ->
    messages = []
    messages = messages.concat(hash.validation) for hash in errors
    messages

  update_error_class: (messages) ->
    @$e ?= $("##{@input_id}")
    return if ember.isBlank(@$e)
    if ember.isBlank(messages) then @$e.removeClass(@error_class) else @$e.addClass(@error_class)
