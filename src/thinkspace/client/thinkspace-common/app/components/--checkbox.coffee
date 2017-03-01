import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend
  classNames:        ['ts-checkbox_button']
  classNameBindings: ['checked:is-checked', 'class']

  toggle_action: null
  checked:       false
  label:         null
  disabled:      false
  disable_click: false
  class:         null

  click: -> @toggle_checked() unless @get('disable_click')

  toggle_checked: ->
    @toggleProperty 'checked'
    @sendAction('toggle_action', @get('checked')) if @get('toggle_action')
