import ember from 'ember'
import base  from 'thinkspace-base/components/base'

# Note: The `onchange={action 'change'}` is due to:
# => https://github.com/emberjs/ember.js/issues/11678#issuecomment-257711434
export default base.extend ember.Evented,
  # # Properties
  tagName: 'div'

  # # Events
  init_base: ->
    @set_input_id()

  # # Helpers
  # ## Getters/setters
  set_input_id: ->
    element_id = @get('elementId')
    @set('input_id', "#{element_id}-input")

  actions:
    change: (event) ->
      target = event.target
      files  = target.files
      unless ember.isEmpty(files)
        @sendAction('changed', files)