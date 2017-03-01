import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend

  errors: {}


  # Properties
  type:              'text'
  show_errors:       true
  has_focused:       false
  initial_validate:  true
  size:              null
  placeholder:       null
  classNameBindings: [':ts-validated-inputu', 'display_errors:has-errors', 'class']

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

  display_errors: ember.computed 'show_errors', 'has_focused', 'initial_validate', 'errors.length', ->
    return false unless @get('show_errors')
    return false unless @get('errors.length')
    return false if (not @get('initial_validate') and not @get('has_focused'))
    return true

  is_text_area: ember.computed.equal 'type', 'textarea'

  # Components
  c_input:          ns.to_p 'common', 'shared', 'input'
  c_text_area:      ns.to_p 'common', 'shared', 'text_area'

  actions:
    save: (value) -> @sendAction 'save', value
    focus_out: -> @set 'has_focused', true; return
