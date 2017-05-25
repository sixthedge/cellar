import ember from 'ember'
import ns    from 'totem/ns'
import ta    from 'totem/ds/associations'
import tc    from 'totem/cache'
import util  from 'totem/util'
import base  from 'thinkspace-base/components/base'

export default base.extend

  server_events: ember.inject.service()
  phase_manager: ember.inject.service()

  # totem_data_config: ability: true, metadata: {ajax_source: true}  # require metadata so completed count will be updated after a submit

  all_phases_completed: null
  is_in_progress:       null
  resume_phase:         null
  team:                 null
  phase_states_loaded:  false

  is_on_team: ember.computed.notEmpty 'team'

  totem_data_config: ability: {ajax_source: true}, metadata: true

  init_base: ->
    @init_assignment_type().then =>
      @init_teams().then =>
        @init_phase_states().then =>
          assignment = @get('model')
          if assignment.get('is_pubsub')
            @totem_scope.authable(assignment)
            se = @get('server_events')
            se.join_assignment_with_current_user()

  init_assignment_type: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get('model')
      model.get(ta.to_p('assignment_type')).then (assignment_type) =>
        @set('assignment_type', assignment_type)
        resolve()

  init_phase_states: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @pm              = @get('phase_manager')
      @pmap            = @get('phase_manager.map')
      assignment       = @get('model')
      ownerable        = @get_ownerable()
      all_phase_states = new Array
      @get('teams').forEach (team) => all_phase_states.pushObject @pmap.get_all(team, assignment)
      phase_states = @pmap.get_all(ownerable, assignment)
      all_phase_states.pushObject(phase_states)
      all_phase_states = util.flatten_array(all_phase_states).compact()
      @set('all_phase_states', all_phase_states)
      @set('phase_states', phase_states)
      @set('phase_states_loaded', true)
      resolve()

  get_ownerable: ->
    ownerable = @pm.get_active_addon_ownerable()
    return ownerable if ember.isPresent(ownerable)
    @pm.get_current_user()

  init_team_set: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get('model')
      model.get(ta.to_p('space')).then (space) =>
        @set('space', space)
        space.get_team_sets().then (team_sets) =>
          @set('team_set', team_sets.get('firstObject'))
          resolve()

  init_teams: ->
    new ember.RSVP.Promise (resolve, reject) =>
      options = 
        verb:   'post'
        action: 'teams_view'
      query =
        sub_action: 'teams'
      @totem_scope.add_authable_to_query(query, @get('model'))
      @tc.query_action(ns.to_p('team'), query, options).then (teams) =>
        @set('teams', teams)
        resolve()

  # set_phase_progress: ->
  #   assignment = @get('model')
  #   assignment.get(ns.to_p 'phases' ).then (phases) =>
  #     phase_promises = phases.getEach(ns.to_p('phase_states'))
  #     ember.RSVP.Promise.all(phase_promises).then =>
  #       sorted_phases = phases.sortBy('position')
  #       resume_phase  = sorted_phases.find (phase) -> phase.get('is_unlocked')
  #       if resume_phase
  #         @set 'resume_phase', resume_phase
  #         @set 'is_in_progress', true  if resume_phase != sorted_phases.get('firstObject')
  #       uncompleted_phase = phases.find (phase) -> phase.get('is_completed') != true
  #       @set 'all_phases_completed', true unless uncompleted_phase
  #       @set 'phase_states_loaded', true
  #     , (error) =>
  #       @totem_messages.api_failure error, source: @, model: ns.to_p('phase_states')
  #   , (error) =>
  #     @totem_messages.api_failure error, source: @, model: ns.to_p('phases')
