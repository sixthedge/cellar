import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.belongs_to 'space', reads: {}
    ta.has_many   'teams', reads: {}
  ), 

  title:       ta.attr('string')
  description: ta.attr('string')
  default:     ta.attr('boolean')
  space_id:    ta.attr('number')
  state:       ta.attr('string')
  settings:    ta.attr()
  metadata:    ta.attr()
  
  # ### State management
  is_locked:       ember.computed.equal 'state', 'locked'
  unlocked_states: ['neutral']
  locked_states:   ['locked']

  # Observer will call a teams get due to the unlocked relationship being needed.
  increment_team_count: ->
    total_teams = @get 'metadata.total_teams'
    @set 'metadata.total_teams', total_teams + 1

  decrement_team_count: ->
    total_teams = @get 'metadata.total_teams'
    @set 'metadata.total_teams', total_teams - 1

  set_unassigned_users_filter: (filter) ->
    @set 'metadata.unassigned_users', filter

  unlocked_teams: ember.computed 'teams', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      @get('teams').then (teams) =>
        records = teams.filter (team) => @get('unlocked_states').contains team.get('state')
        resolve(records)
    ta.PromiseArray.create promise: promise

  locked_teams: ember.computed 'teams', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      @get('teams').then (teams) =>
        records = teams.filter (team) => @get('locked_states').contains team.get('state')
        resolve(records)
    ta.PromiseArray.create promise: promise

  unassigned_users_count: ember.computed 'metadata.unassigned_users', ->
    count = @get 'metadata.unassigned_users'
    if count.then? then count.get('length') else count

  total_teams_count: ember.computed 'metadata.total_teams', ->
    count = @get 'metadata.total_teams'
    if count.then? then count.get('length') else count

