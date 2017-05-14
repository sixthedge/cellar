import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.has_many 'users'
    ta.has_many 'users', type: ta.to_p('owner'), reads: {name: 'owners'}
    ta.has_many 'space_types', reads: {}
    ta.has_many 'assignments', reads: [{sort: 'title'}, {name: 'assignments_due_at_asc', sort: ['due_at:asc', 'title:asc']}]
    # ta.has_many 'team_sets', reads: {}
  ),


  title:     ta.attr('string')

  immediate_assignment: ember.computed.reads 'assignments_due_at_asc.firstObject'
  # active_assignments:   ember.computed.filterBy 'assignments_due_at_asc', 'active', true
  # inactive_assignments: ember.computed.filterBy 'assignments_due_at_asc', 'active', false
  
  active_assignments: ember.computed.filterBy 'assignments_due_at_asc', 'state', 'active'
  draft_assignments: ember.computed.filterBy 'assignments_due_at_asc', 'state', 'inactive'
  archived_assignments: ember.computed.filterBy 'assignments_due_at_asc', 'state', 'archived'

  valid_roles:          ['read', 'update', 'owner']

  normalizeModelName: (mn) ->
    console.warn 'NORMALIZE MODEL NAME:', mn
    @_super(mn)

  get_team_sets: (options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      params = 
        id: @get('id')
      options =
        action: 'team_sets'
        model:  ta.to_p('team_set')
      @tc.query_action(ta.to_p('space'), params, options).then (team_sets) =>
        # team_sets = team_sets.filter (team_set) => team_set.get('unlocked_states').includes team_set.get('state') unless options.include_locked
        resolve(team_sets)
    , (error) => console.error "[space model] Error in get_team_sets.", error

  get_default_team_set: (options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @get_team_sets().then (team_sets) =>
        team_set = team_sets.findBy('is_default')
        resolve(team_set)
    , (error) => console.error "[space model] Error in get_default_team_set.", error

  get_teams: (options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      params =
        id: @get('id')
      options =
        action: 'teams'
        model: ta.to_p('team')
      @tc.query_action(ta.to_p('space'), params, options).then (teams) =>
        resolve(teams)
    , (error) => console.error "[space model] Error in get_teams.", error

  unlocked_team_sets: ember.computed 'team_sets', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      @get('team_sets').then (team_sets) =>
        records = team_sets.filter (team_set) => team_set.get('unlocked_states').includes team_set.get('state')
        resolve(records)
    ta.PromiseArray.create promise: promise

  locked_team_sets: ember.computed 'team_sets', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      @get('team_sets').then (team_sets) =>
        records = team_sets.filter (team_set) => team_set.get('locked_states').includes team_set.get('state')
        resolve(records)
    ta.PromiseArray.create promise: promise

  add_ability: (abilities) ->
    update            = abilities.update or false
    abilities.update  = update
    abilities.destroy = update
