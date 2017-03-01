import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'
import ta    from 'totem/ds/associations'
import tc    from 'totem/cache'

export default base.extend

  server_events: ember.inject.service()

  # totem_data_config: ability: true, metadata: {ajax_source: true}  # require metadata so completed count will be updated after a submit

  all_phases_completed: null
  is_in_progress:       null
  resume_phase:         null
  team:                 null
  phase_states_loaded:  false

  is_on_team: ember.computed.notEmpty 'team'

  init_base: ->
    @set_phase_progress()
    @init_assignment_type()
    @init_team_set().then =>
      @init_team()
      @init_assessment_phase()
      assignment = @get('model')
      if assignment.get('is_pubsub')
        @totem_scope.authable(assignment)
        se = @get('server_events')
        se.join_assignment_with_current_user()

  init_assignment_type: ->
    model = @get('model')
    model.get(ta.to_p('assignment_type')).then (assignment_type) =>
      @set('assignment_type', assignment_type)

  init_assessment_phase: ->
    model = @get('model')
    model.get(ta.to_p('phases')).then (phases) =>
      console.log('[init_assessment_phase] phases are ', phases)

      return unless ember.isPresent(phases)
      return if phases.get('length') > 1
      @set('phase', phases.get('firstObject'))

  init_team_set: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get('model')
      model.get(ta.to_p('space')).then (space) =>
        @set('space', space)
        space.get_team_sets().then (team_sets) =>
          @set('team_set', team_sets.get('firstObject'))
          resolve()
            
  init_team: ->
    team_set = @get('team_set')
    console.log('team_set is ', team_set, ta.to_p('team'))

    query =
      id: team_set.get('id')

    options =
      action: 'teams'
      model: ta.to_p('team')

    tc.query_action(ta.to_p('team_set'), query, options).then (teams) =>
      team = teams.filterBy 'is_member', true
      @set('team', team.get('firstObject'))

  set_phase_progress: ->
    assignment = @get('model')
    assignment.get(ns.to_p 'phases' ).then (phases) =>
      console.log('[SET_PHASE_PROGRESS] phases are ', phases)
      phase_promises = phases.getEach(ns.to_p('phase_states'))
      ember.RSVP.Promise.all(phase_promises).then =>
        sorted_phases = phases.sortBy('position')
        resume_phase  = sorted_phases.find (phase) -> phase.get('is_unlocked')
        if resume_phase
          @set 'resume_phase', resume_phase
          @set 'is_in_progress', true  if resume_phase != sorted_phases.get('firstObject')
        uncompleted_phase = phases.find (phase) -> phase.get('is_completed') != true
        @set 'all_phases_completed', true unless uncompleted_phase
        @set 'phase_states_loaded', true
      , (error) =>
        @totem_messages.api_failure error, source: @, model: ns.to_p('phase_states')
    , (error) =>
      @totem_messages.api_failure error, source: @, model: ns.to_p('phases')
