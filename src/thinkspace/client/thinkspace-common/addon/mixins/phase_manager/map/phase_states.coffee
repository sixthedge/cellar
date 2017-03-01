import ember from 'ember'

export default ember.Mixin.create

  set_phases:           (ownerable, assignment, phases)       -> @get_amap(ownerable, assignment).set 'phases', phases
  get_phases:           (ownerable, assignment)               -> @get_amap(ownerable, assignment).get('phases') or []
  set_has_phase_states: (ownerable, assignment, tf)           -> @get_amap(ownerable, assignment).set('has_phase_states', tf == true)
  has_phase_states:     (ownerable, assignment)               -> @get_amap(ownerable, assignment).get('has_phase_states') == true
  set_global:           (ownerable, assignment, phase_state)  -> @get_amap(ownerable, assignment).set 'global', phase_state
  get_global:           (ownerable, assignment)               -> @get_amap(ownerable, assignment).get 'global'
  set_all:              (ownerable, assignment, phase_states) -> @get_amap(ownerable, assignment).set 'phase_states', phase_states
  get_all:              (ownerable, assignment)               -> @get_amap(ownerable, assignment).get 'phase_states'

  set_selected:     (ownerable, phase, phase_state)  -> @get_pmap(ownerable, phase).set 'selected', phase_state
  get_selected:     (ownerable, phase)               -> @get_pmap(ownerable, phase).get 'selected'
  set_phase_states: (ownerable, phase, phase_states) -> @get_pmap(ownerable, phase).set('phase_states', phase_states)
  get_phase_states: (ownerable, phase)               -> @get_pmap(ownerable, phase).get('phase_states') or []

  get_current_user_selected: (phase) -> @get_selected(@pm.get_current_user(), phase)

  get_current_user_phases:      (assignment) -> @get_phases(@pm.get_current_user(), assignment)
  get_current_ownerable_phases: (assignment) -> @get_phases(@pm.get_ownerable(), assignment)

  get_current_user_phase_states:      (phase) -> @get_phase_states(@pm.get_current_user(), phase)
  get_current_ownerable_phase_states: (phase) -> @get_phase_states(@pm.get_ownerable(), phase)

  has_multiple_phase_states: (ownerable, phase) ->
    phase_states = @get_phase_states(ownerable, phase)
    phase_states and phase_states.get('length') > 1

  filter_phase_states_for_phase: (phase, phase_states) ->
    phase_id     = parseInt(phase.get 'id')
    phase_states = phase_states.filterBy('phase_id', phase_id)
    phase_states.sortBy 'title'
