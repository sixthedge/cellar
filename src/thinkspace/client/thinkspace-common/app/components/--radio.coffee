import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend

  toggle_action:     null
  checked:           false
  disabled:          false
  label:             null
  disable_click:     false
  class:             null
  classNameBindings: ['checked:is-checked', 'class']
  classNames:        ['ts-radio_button']

  click: -> @toggle_checked() unless @get('disable_click')

  toggle_checked: ->
    @toggleProperty 'checked'
    @sendAction('toggle_action', @get('checked')) if @get('toggle_action')