import ember from 'ember'

# The `save` property proxies up to the validated_input.
export default ember.TextArea.extend
  type: 'text'
  classNames: ['ts-validated-input_input']

  focusOut: -> 
    @sendAction 'save', @get('value')
    @sendAction 'focus_out'