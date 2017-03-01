import ember from 'ember'
import ns    from 'totem/ns'
import util  from 'totem/util'
import base  from 'thinkspace-base/services/base'
import totem_changeset from 'totem/changeset'
import totem_messages  from 'totem-messages/messages'

export default base.extend

  phase_manager: ember.inject.service()

  map:                        null
  phase_score_validation_map: null

  init: ->
    @_super(arguments...)
    console.warn '==========================gradebook service init=============================='
    @thinkspace                 = @get('thinkspace')
    @phase_manager              = @get('phase_manager')
    @register_change_components = []
    @map                        = @new_map()
    @phase_score_validation_map = @new_map()

  register_change_component: (component) -> @register_change_components.push(component)

  call_change_components: (change={}) ->
    destroyed_components = []
    for comp in @register_change_components
      if comp.is_destroyed()
        destroyed_components.push(comp)
      else
        comp.register_change_callback(change)
    @register_change_components.removeObject(comp) for comp in destroyed_components

  # ###
  # ### Helpers
  # ###

  toString: -> 'Gradebook'

  current_space:      -> @thinkspace.get_current_space()
  current_assignment: -> @thinkspace.get_current_assignment()
  current_phase:      -> @thinkspace.get_current_phase()
  addon_ownerable:    -> @phase_manager.get_active_addon_ownerable()

  is_destroyed: (component) -> util.is_destroyed(@) or util.is_destroyed(component)

  reset: ->
    @clear()
    @phase_manager.reset()

  clear: ->
    @clear_registered_components()

  clear_registered_components: -> @register_change_components.clear()

  open_addon: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @clear()
      @set_phase_score_validations().then =>
        resolve()

  close_addon: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @clear()
      resolve()

  # ###
  # ### Phase Validation Helpers.
  # ###

  get_phase_score_validation: (phase) -> @phase_score_validation_map.get(phase) or {}
  get_phase_score_decimals:   (phase) -> (@phase_score_validation_map.get(phase) or @get_default_score_validation()).decimals or 0

  set_phase_score_validations: ->
    new ember.RSVP.Promise (resolve, reject) =>
      assignment = @get('thinkspace').get_current_assignment()
      assignment.get(ns.to_p 'phases').then (phases) =>
        phases.forEach (phase) =>
          validation = phase.get('settings.phase_score_validation') or {}
          rules      = validation.numericality or @get_default_score_validation()
          rules      = totem_changeset.convert_number_rules_to_changeset(rules)
          @phase_score_validation_map.set phase, rules
        resolve()

  get_default_score_validation: ->
    validation =
      allow_blank:              true
      greater_than_or_equal_to: 0
      less_than_or_equal_to:    10
      decimals:                 0

  get_phase_score_max_decimals: ->
    max = 0
    @phase_score_validation_map.forEach (validation) =>
      decimals = Number(validation.decimals or 0)
      max      = decimals if decimals > max
    max

  # ###
  # ### Map helpers.
  # ###

  new_map: -> ember.Map.create()
  get_map: -> @get 'map'

  get_or_init_map: ->
    unless map = @get_map()
      @set 'map', @new_map()
      map = @get_map()
    map

  get_or_init_space_map: (space)           -> @get_or_init_record_map(space)
  get_or_init_assignment_map: (assignment) -> @get_or_init_record_map(assignment)

  get_or_init_phase_map: (assignment, phase) ->
    assignment_map = @get_or_init_assignment_map(assignment)
    phase_map      = assignment_map.get(phase)
    assignment_map.set phase, @new_map()  unless phase_map
    assignment_map.get(phase)

  get_or_init_record_map: (record) ->
    map       = @get_or_init_map()
    record_map = map.get(record)
    map.set record, @new_map() unless record_map
    map.get(record)

  # ###
  # ### Ownerables.
  # ###

  is_phase_team_ownerables: (phase=@current_phase()) -> phase and phase.get('is_team_collaboration')

  is_team_ownerable: (ownerable) -> util.is_model_type(ownerable, ns.to_p 'team')

  get_ownerables: ->
    new ember.RSVP.Promise (resolve, reject) =>
      assignment = @current_assignment()
      phase      = @current_phase()
      if @is_phase_team_ownerables(phase)
        @get_teams(assignment, phase).then (teams) =>
          resolve(teams)
      else
        space = @current_space()
        @get_users(space, assignment, phase).then (users) => resolve(users)

  get_selected_ownerable: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @addon_ownerable_valid().then (valid) =>
        ownerable = if valid then @addon_ownerable() else null
        resolve(ownerable)

  # get_selected_ownerable: ->
  #   new ember.RSVP.Promise (resolve, reject) =>
  #     @addon_ownerable_valid().then (valid) =>
  #       if valid
  #         resolve @addon_ownerable()
  #       else
  #         @get_ownerables().then (ownerables) =>
  #           # If want a way to select one of the ownerables (e.g. a team the user is a member, a user that is on team, etc.)
  #           # could save previous ownerable in e.g. phase_manager.map.
  #           ownerable = ownerables.get('lastObject') # picking one to test only
  #           if ownerable
  #             @change_ownerable(ownerable)
  #             resolve(ownerable)
  #           else
  #             resolve(null)

  change_ownerable: (ownerable) ->
    util.error @, "Change-to ownerable is blank."  unless ownerable
    @totem_scope.view_only_on()
    @phase_manager.set_addon_ownerable_and_generate_view(ownerable).then =>
      @call_change_components(ownerable: true)

  get_current_team: (ownerables) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve(null) unless @is_phase_team_ownerables()
      @get_phase_manager_map_selected_ownerable().then (ownerable) =>
        if @is_team_ownerable(ownerable) then resolve(ownerable) else resolve(null)

  get_phase_manager_map_selected_ownerable: ->
    new ember.RSVP.Promise (resolve, reject) =>
      phase        = @current_phase()
      map          = @phase_manager.map
      current_user = @totem_scope.get_current_user()
      phase_state  = map.get_selected(current_user, phase)
      if ember.isBlank(phase_state)
        resolve(current_user)
      else
        phase_state.get('ownerable').then (ownerable) =>
          if ember.isBlank(ownerable) then resolve(current_user) else resolve(ownerable)

  addon_ownerable_valid: ->
    new ember.RSVP.Promise (resolve, reject) =>
      ownerable = @addon_ownerable()
      return resolve(false) if ember.isBlank(ownerable)
      @get_ownerables().then (ownerables) =>
        return resolve(false) if ember.isBlank(ownerables)
        resolve ownerables.includes(ownerable)

  valid_addon_ownerable: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @addon_ownerable_valid().then (valid) => if valid then resolve() else reject()

  # ###
  # ### Gradebook Users - all space users.
  # ###

  get_users: (space, assignment, phase) ->
    new ember.RSVP.Promise (resolve, reject) =>
      space_map       = @get_or_init_space_map(space)
      gradebook_users = space_map.get 'gradebook_users'
      return resolve(gradebook_users) if ember.isPresent(gradebook_users)
      current_user = @totem_scope.get_current_user()
      @tc.view_payload(assignment, sub_action: 'gradebook_users', ownerable: current_user, authable: phase, reload: true).then (payload) =>
        users           = @tc.push_payload_and_return_records_for_type payload, ns.to_p('user')
        gradebook_users = users.sortBy 'sort_name'
        space_map.set 'gradebook_users', gradebook_users
        resolve gradebook_users

  # ###
  # ### Gradebook Teams - all phase teams for an assignment.
  # ###

  get_teams: (assignment, phase) ->
    new ember.RSVP.Promise (resolve, reject) =>
      phase_map = @get_or_init_phase_map(assignment, phase)
      teams     = phase_map.get 'teams'
      return resolve(teams) if teams
      current_user = @totem_scope.get_current_user()
      @tc.view_payload(assignment, sub_action: 'gradebook_teams', ownerable: current_user, authable: phase, reload: true).then (payload) =>
        teams           = @tc.push_payload_and_return_records_for_type payload, ns.to_p('team')
        teams           = teams.uniq()
        gradebook_teams = teams.sortBy 'title'
        phase_map       = @get_or_init_phase_map(assignment, phase)
        phase_map.set 'teams', gradebook_teams
        resolve gradebook_teams
