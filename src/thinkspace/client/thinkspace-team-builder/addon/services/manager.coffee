import ember          from 'ember'
import base           from 'thinkspace-base/services/base'
import totem_messages from 'totem-messages/messages'
import ns             from 'totem/ns'
import util           from 'totem/util'

export default base.extend

  space:    null
  abstract: null
  team_set: null

  is_transform: ember.computed 'has_transform', ->
    if @get('has_transform')
      return 'TRANSFORM'
    else
      return 'SCAFFOLD'

  has_transform: ember.computed.notEmpty 'team_set.transform'

  teams: ember.computed 'has_transform', ->
    if @get('has_transform')
      @get('team_set.transform.teams')
    else
      @get('team_set.scaffold.teams')

  set_space: (space) -> @set('space', space) if ember.isPresent(space)

  initialize: ->
    new ember.RSVP.Promise (resolve, reject) =>
      space = @get('space')
      resolve() unless ember.isPresent(space)
      @init_team_set().then (team_set) =>
        @init_abstract().then (abstract) =>
          resolve()

  init_team_set: ->
    new ember.RSVP.Promise (resolve, reject) =>
      space = @get('space')
      resolve() unless ember.isPresent(space)
      space.get_team_sets().then (team_sets) =>
        team_set = team_sets.get('firstObject')
        resolve() unless ember.isPresent(team_set)
        @set('team_set', team_set)
        resolve(team_set)

  init_abstract: ->
    new ember.RSVP.Promise (resolve, reject) =>
      team_set = @get('team_set')
      resolve() unless ember.isPresent(team_set)
      params =
        id: team_set.get('id')
      options =
        action: 'abstract'

      @tc.query_data(ns.to_p('team_set'), params, options).then (json) =>
        @set('abstract', json)
        resolve(json)


  save_transform: ->
    new ember.RSVP.Promise (resolve, reject) =>
      team_set = @get('team_set')
      params =
        id:        team_set.get('id')
        transform: team_set.get('transform')

      options =
        action: 'update_transform'
        verb:   'PUT'

      @tc.query_action(ns.to_p('team_set'), params, options).then (team_set) =>
        resolve(team_set)

  generate_transform: ->
    return if @get('has_transform')
    team_set = @get('team_set')
    team_set.set('transform', ember.copy(team_set.get('scaffold'), true))

  ####
  ## Team functions
  ####
  remove_from_team: (team_id, user) ->
    @generate_transform()
    team = @get_team_by_id(team_id)
    team.user_ids.removeObject(user.id)
    user.team_id = null

  add_to_team: (team_id, user) ->
    @generate_transform()
    team = @get_team_by_id(team_id)
    team.user_ids.pushObject(user.id)
    user.team_id = team.id

  get_team_by_id: (id) ->
    teams = @get('teams')
    team  = teams.findBy 'id', id
    team