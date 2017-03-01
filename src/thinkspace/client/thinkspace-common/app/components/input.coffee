import ember from 'ember'

# The `save` property proxies up to the validated_input.
export default ember.TextField.extend
  type: 'text'
  classNames: ['ts-validated-inpuut_input']

  focusOut: ->
    @sendAction 'save', @get('value')
    @sendAction 'focus_out'
