import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName: ''

  phase_manager: ember.inject.service()
  gradebook:     ember.inject.service()

  addon_ownerable:    ember.computed.reads 'addons.active_addon_ownerable'
  current_phase:      ember.computed.reads 'thinkspace.current_phase'
  current_assignment: ember.computed.reads 'thinkspace.current_assignment'

  is_viewing_total_score: false
  is_viewing_phase_state: false

  is_team_collaboration: false
  phase_state:           null
  total_score:           null

  init_base: ->
    @pm        = @get('phase_manager')
    @pmap      = @get('phase_manager.map')
    @gradebook = @get('gradebook')
    @gradebook.register_change_component(@)
    @calc_and_set_total_score()

  actions:
    phase_score: (phase, score) -> @save_phase_score(phase, score)
    phase_state: (phase, state) -> @save_phase_state(phase, state)
    delete_ownerable_data:      -> @delete_ownerable_data()

    toggle_is_viewing_phase_state: -> @set('is_viewing_total_score', false) if @toggleProperty('is_viewing_phase_state')
    toggle_is_viewing_total_score: -> @set('is_viewing_phase_state', false) if @toggleProperty('is_viewing_total_score')

  register_change_callback: (change={}) ->
    return unless (change.phase or change.ownerable)
    @calc_and_set_total_score()

  call_change_components: (change={}) -> @gradebook.call_change_components(change)

  set_total_score: (score) -> @set 'total_score', score

  calc_and_set_total_score: ->
    assignment = @get 'current_assignment'
    if ember.isBlank(assignment)
      @set_total_score(0)
      return
    assignment.get(ns.to_p 'phases').then (phases) =>
      if ember.isBlank(phases)
          @set_total_score(0)
          return
      total = 0
      phases.forEach (phase) =>
        phase_states = @pmap.get_current_ownerable_phase_states(phase)
        phase_states.forEach (phase_state) =>
          total += Number(phase_state.get('score') or 0)
      decimals = @gradebook.get_phase_score_max_decimals()
      total    = total.toFixed(decimals)
      @set_total_score(total)

  save_phase_score: (phase, score) ->
    phase_state = phase.get('phase_state')
    phase_state.get(ns.to_p 'phase_score').then (phase_score) =>
      unless phase_score
        phase_score = @tc.create_record ns.to_p('phase_score')
        phase_score.set ns.to_p('phase_state'), phase_state
      score = Number(score)  # score is text but the model attribute is a Number; convert to a number for isDirty check
      phase_score.set 'score', score
      if phase_score.get('hasDirtyAttributes')
        phase_score.save().then (record) =>
          @totem_messages.api_success source: @, model: record, action: 'save', i18n_path: ns.to_o('phase_score', 'save')
          #@focus_on_score_input()
          @calc_and_set_total_score()
          @call_change_components(score: true)
        , (error) =>
          @totem_messages.api_failure error, source: @, model: phase_score

  save_phase_state: (phase, state) ->
    phase_state = phase.get('phase_state')
    unless phase_state.get('current_state') == state
      phase_state.set 'new_state', state
      phase_state.save().then (record) =>
        @totem_messages.api_success source: @, model: record, action: 'save', i18n_path: ns.to_o('phase_state', 'save')
        # @call_change_components(state: true)
        #@focus_on_score_input()
      , (error) =>
        @totem_messages.api_failure error, source: @, model: phase_state

  delete_ownerable_data: ->
    ownerable = @get 'addon_ownerable'
    phase     = @get 'current_phase'
    confirm   = window.confirm "Are you sure you want to clear #{ownerable.get('first_name')}'s data for #{phase.get('title')}?  This will remove all of their responses for this phase.  This process is NOT REVERSIBLE.  This will refresh your browser."
    if confirm
      query =
        id:             phase.get('id')
        ownerable_id:   ownerable.get('id')
        ownerable_type: @totem_scope.standard_record_path(ownerable)
        action:         'delete_ownerable_data'
        verb:           'PUT'
      @totem_messages.show_loading_outlet(message: 'Removing learner data...')
      @tc.query(ns.to_p('phase'), query, single: true).then =>
        @calc_and_set_total_score()
        @totem_messages.hide_loading_outlet()
        # location.reload() # TODO: Temporary until we figure out how to handle this in Ember.
        # @set_addon_ownerable(ownerable).then =>
        #   @totem_messages.hide_loading_outlet()
        #   location.reload() # TODO: Temporary until we figure out how to handle this in Ember.
