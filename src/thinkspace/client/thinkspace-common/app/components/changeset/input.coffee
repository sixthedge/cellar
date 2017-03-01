import ember from 'ember'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  tvo: ember.inject.service()

  errors_visible: ember.computed.or 'tvo.show_errors', 'changeset.show_errors'
  display_errors: ember.computed.and 'errors_visible', 'has_focused_out'

  # Properties
  type:              'text'
  classNameBindings: [':forms__field-wrapper', 'display_errors:has-errors', 'class']

  poll: false

  # Some browsers do not trigger a 'change' event on the input if the field is autofilled
  # To fully account for this issue, poll to ensure that ember can catch input changes made by autofill
  autofill_poll: (->
    return unless @get('poll')
    ember.run.later @, ( =>
      return unless ember.isPresent(@) and ember.isPresent(@$()) and @get('poll')
      @$('input').trigger('change')
      @autofill_poll()
    ), 250
  ).on('didInsertElement')

  actions:

    focus_out: -> @set 'has_focused_out', true

