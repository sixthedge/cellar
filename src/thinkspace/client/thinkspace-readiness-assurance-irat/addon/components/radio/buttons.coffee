import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend
  # # Properties
  tagName:           'div'
  classNameBindings: ['no_errors::ts-ra_error']

  # # Computed properties
  value:            ember.computed.reads 'qm.answer_id'
  buttons_disabled: ember.computed.or 'qm.readonly', 'qm.answers_disabled'

  # # Events
  init_base: -> @set_options()

  # # Helpers
  set_options: ->
    question = @get('qm.question')
    choices  = @get('qm.choices')
    # Map the `id` to `value` for the accessibility radios.
    choices.forEach (choice) =>
      choice.value    = choice.id
      choice.disabled = @get('buttons_disabled')
    options  = 
      group:
        label: question
      choices: choices
    @set('options', options)

  actions:
    select: (id) -> @sendAction 'select', id
