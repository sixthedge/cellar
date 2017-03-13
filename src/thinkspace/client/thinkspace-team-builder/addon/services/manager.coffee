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

  has_transform: ember.computed.reads 'team_set.has_transform'

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
    ember.set user, 'team_id', team.id

  get_team_by_id: (id) ->
    teams = @get('teams')
    team  = teams.findBy 'id', id
    team

  get_user_ids: (users) -> users.map (user) -> parseInt(user.id)

  generate_new_team_id: ->
    ms = new Date().getTime()

    ms_str = ms.toString()
    ms_str = ms_str.slice(4)
    console.log('ms_string ', ms_str)
    ms_str

  create_team: (options) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @generate_transform()
      title    = options.title                if ember.isPresent(options.title)
      color    = options.color                if ember.isPresent(options.color)
      if ember.isPresent(options.user_ids)
        user_ids = options.user_ids
      else if ember.isPresent(options.users)
        console.log('options.users are ', options.users)
        user_ids = @get_user_ids(options.users)
        console.log('user_ids are ', user_ids)

      team          = {}
      team.id       = @generate_new_team_id()
      team.title    = title || 'New Team'
      team.color    = color || 'eeeeee'
      team.user_ids = ember.makeArray(user_ids) || [] if ember.isPresent(user_ids)
      team.new      = true

      @add_team_to_transform(team).then (saved_team) =>
        resolve(saved_team)

  add_team_to_transform: (team) ->
    new ember.RSVP.Promise (resolve, reject) =>
      team_set = @get('team_set')
      transform = team_set.get('transform')

      teams = transform.teams
      teams.pushObject(team)

      console.log('team_set is ', team_set)

      @save_transform().then (saved) =>
        console.log('[add_team_to_transform] POST SAVE ', saved)
        resolve(team)