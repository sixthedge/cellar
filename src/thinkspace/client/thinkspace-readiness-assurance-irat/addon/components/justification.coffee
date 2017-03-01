import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend

  input_value: null

  justification_disabled: ember.computed.or 'qm.readonly', 'qm.justification_disabled'

  actions:
    save: ->
      return if @get('justification_disabled')
      @sendAction 'save', @get('input_value')
      @set 'show_save', false

  focusOut: -> @send 'save'

  init_base: ->
    @set 'input_value', @qm.justification
