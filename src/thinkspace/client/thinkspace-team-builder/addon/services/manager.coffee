import ember          from 'ember'
import base           from 'thinkspace-base/services/base'
import totem_messages from 'totem-messages/messages'
import ns             from 'totem/ns'
import util           from 'totem/util'
import arr_helpers    from 'thinkspace-common/mixins/helpers/common/array'

export default base.extend arr_helpers,

  space:    null
  abstract: null
  team_set: null

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
          console.log('Abstract is:', abstract)
          @reconcile_assigned_users()
          resolve()

  reinitialize: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @initialize().then =>
        resolve()

  reconcile_assigned_users: ->
    abstract = @get('abstract')
    users    = abstract.users
    teams    = abstract.teams

    teams.forEach (team) =>
      user_ids   = team.user_ids
      unless ember.isEmpty(user_ids)
        team_users = users.filter (user) -> user_ids.contains(parseInt(user.id))
        unless ember.isEmpty(team_users)
          team_users.forEach (user) =>
            user.team_id = team.id

  init_team_set: ->
    new ember.RSVP.Promise (resolve, reject) =>
      space = @get('space')
      resolve() unless ember.isPresent(space)
      space.get_default_team_set().then (team_set) =>
        console.log "TS IS:", team_set
        resolve() unless ember.isPresent(team_set)
        @set('team_set', team_set)
        resolve(team_set)

  init_abstract: ->
    new ember.RSVP.Promise (resolve, reject) =>
      console.log('Calling init_abstract')
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

  explode: ->
    new ember.RSVP.Promise (resolve, reject) =>
      team_set = @get('team_set')
      params =
        id: team_set.get('id')

      options =
        action: 'explode'
        verb: 'PUT'

      @tc.query_action(ns.to_p('team_set'), params, options).then (team_set) =>
        @reinitialize().then =>
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
    @remove_from_team(user.team_id, user) if user.team_id != team_id and ember.isPresent(user.team_id)
    team = @get_team_by_id(team_id)
    team.user_ids.pushObject(user.id)
    ember.set user, 'team_id', team.id

  get_team_by_id: (id) ->
    teams = @get('teams')
    team  = teams.findBy 'id', id
    team

  revert_team: (team_id, image) ->
    teams = @get('teams')
    team  = teams.findBy 'id', team_id

    ember.set(team, 'title', image.title)
    ember.set(team, 'color', image.color) 
    ember.set(team, 'user_ids', image.user_ids)
    team

  get_user_ids: (users) -> users.map (user) -> parseInt(user.id)

  generate_new_team_id: ->
    ms     = new Date().getTime()
    ms_str = ms.toString()
    ms_str = ms_str.slice(4)
    parseInt(ms_str)

  create_team: (options) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @generate_transform()
      title    = options.title                if ember.isPresent(options.title)
      color    = options.color                if ember.isPresent(options.color)
      if ember.isPresent(options.user_ids)
        user_ids = options.user_ids
      else if ember.isPresent(options.users)
        user_ids = @get_user_ids(options.users)

      team          = {}
      team.id       = @generate_new_team_id()
      team.title    = title || 'New Team'
      team.color    = color || 'eeeeee'
      team.user_ids = ember.makeArray(user_ids) || [] if ember.isPresent(user_ids)
      team.new      = true

      @add_team_to_transform(team).then (saved_team) =>
        #@add_users_to_transform(team).then =>
        resolve(saved_team)

  add_users_to_transform: (team) ->
    new ember.RSVP.Promise (resolve, reject) =>
      abstract  = @get('abstract')
      team_set  = @get('team_set')
      transform = team_set.get('transform')
      transform.users = [] unless ember.isPresent(transform.users)

      users = @where_in(abstract.users, 'id', team.user_ids)

      users.forEach (user) =>
        user.team_id = team.id
        transform.users.pushObject(user)

      @save_transform().then (saved) =>
        resolve()

  add_team_to_transform: (team) ->
    new ember.RSVP.Promise (resolve, reject) =>
      team_set  = @get('team_set')
      transform = team_set.get('transform')
      teams     = transform.teams
      teams.pushObject(team)
      @save_transform().then (saved) =>
        resolve(team)

  remove_team_from_transform: (team) ->
    new ember.RSVP.Promise (resolve, reject) =>
      teams = @get('teams')
      teams.removeObject(team) if teams.contains(team)
      @save_transform().then (saved) =>
        @reconcile_assigned_users()
        resolve()
