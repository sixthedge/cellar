import ember          from 'ember'
import base           from 'thinkspace-base/services/base'
import totem_messages from 'totem-messages/messages'
import ns             from 'totem/ns'
import util           from 'totem/util'
import arr_helpers    from 'thinkspace-common/mixins/helpers/common/array'

export default base.extend arr_helpers,

  # ### Properties
  space:    null
  abstract: null
  team_set: null

  # ### Computed Properties
  has_transform: ember.computed.reads 'team_set.has_transform'

  teams: ember.computed 'has_transform', 'transform.teams.@each', 'scaffold.teams.@each', ->
    if @get('has_transform')
      @get('team_set.transform.teams')
    else
      @get('team_set.scaffold.teams')

  has_teams: ember.computed.notEmpty 'teams'

  set_space: (space) -> @set('space', space) if ember.isPresent(space)

  # ### Initialization
  initialize: ->
    new ember.RSVP.Promise (resolve, reject) =>
      space = @get('space')
      resolve() unless ember.isPresent(space)
      @init_team_set().then (team_set) =>
        @init_abstract().then (abstract) =>
          @reconcile_assigned_users()
          resolve()

  init_team_set: ->
    new ember.RSVP.Promise (resolve, reject) =>
      space = @get('space')
      resolve() unless ember.isPresent(space)
      space.get_default_team_set().then (team_set) =>
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

  reinitialize: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @initialize().then =>
        resolve()

  # ### Helpers
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

  generate_transform: ->
    return if @get('has_transform')
    team_set = @get('team_set')
    team_set.set('transform', ember.copy(team_set.get('scaffold'), true))

  # ### Queries
  save_transform: ->
    new ember.RSVP.Promise (resolve, reject) =>
      team_set = @get('team_set')
      params   =
        transform: team_set.get('transform')

      @team_set_query_action('update_transform', 'PUT', params).then (team_set) =>
        @init_abstract().then (new_abstract) =>
          @reconcile_assigned_users()
          resolve(team_set)

  revert_transform: ->
    new ember.RSVP.Promise (resolve, reject) =>
      team_set = @get('team_set')
      team_set.rollbackAttributes() # ember will not update 'dirty' attributes even with new information from the server
      params =
        transform: {}

      @team_set_query_action('update_transform', 'PUT', params).then (team_set) =>
        resolve(team_set)

  explode: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @team_set_query_action('explode', 'PUT', {}).then (team_set) =>
        @reinitialize().then =>
          resolve(team_set)

  team_set_query_action: (action, verb, params={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      params.id = @get('team_set.id')

      options =
        action: action
        verb:   verb
        single: true

      @tc.query_action(ns.to_p('team_set'), params, options).then (team_set) =>
        resolve(team_set)

  # ### Team functions
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
        resolve(saved_team)

  add_users_to_transform: (team) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @generate_transform()
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
      @generate_transform()
      team_set  = @get('team_set')
      transform = team_set.get('transform')
      teams     = transform.teams
      teams.pushObject(team)
      @save_transform().then (saved) =>
        resolve(team)

  remove_team_from_transform: (team) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @generate_transform()
      teams = @get('teams')
      @remove_objects_with_value(teams, 'id', team.id)
      @save_transform().then (saved) =>
        @reconcile_assigned_users()
        resolve()

  update_title_for_team: (team, title) -> @update_attribute_for_team(team, 'title', title)
  update_color_for_team: (team, color) -> @update_attribute_for_team(team, 'color', color)

  update_attribute_for_team: (team, attr, value) ->
    return if value == team[attr]
    @generate_transform()
    team = @get_team_by_id(team.id)
    ember.set(team, attr, value)

  # ### Private
  _debug: (message, args...) ->
    console.log "[tb/manager] #{message}", args...
