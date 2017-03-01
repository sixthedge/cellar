import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName: ''

  phase_manager: ember.inject.service()

  show_phase: true

  # Caution: This must an 'init' not an 'init_base'.
  init: ->
    @_super(arguments...)
    @get('phase_manager').set_current_phase_show_component(@)

  set_show_phase_on:  -> @set 'show_phase', true
  set_show_phase_off: -> @set 'show_phase', false
