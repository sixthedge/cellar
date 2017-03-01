import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend

  show_save:   false
  input_value: null

  willInsertElement: -> @set_input_value()

  justification_disabled: ember.computed.or 'qm.readonly', 'qm.justification_disabled'

  justification_change:   ember.observer 'qm.justification', -> @set_input_value()
    
  set_input_value: -> @set 'input_value', @qm.justification

  actions:
    save: ->
      return if @get('justification_disabled')
      @sendAction 'save', @get('input_value')
      @set 'show_save', false

    cancel: ->
      @set_input_value()
      @sendAction 'cancel'
      @set 'show_save', false

  focusIn: ->
    @sendAction 'focus_in'
    @set 'show_save', true
