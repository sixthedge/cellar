import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'

export default base.extend

  state_buttons: [
    {id: 'lock',     label: 'Locked'}
    {id: 'unlock',   label: 'Unlocked'}
    {id: 'complete', label: 'Completed'}
  ]

  init_base: -> @validate = @rad.validate

  actions:
    select: (state) ->
      @set 'selected_state', state
      @rad.set_phase_state(state)
      @sendAction 'validate' if @validate
