import ember          from 'ember'
import ns             from 'totem/ns'
import base_component from 'thinkspace-base/components/base'
import arr_helpers    from 'thinkspace-common/mixins/helpers/common/array'


export default base_component.extend arr_helpers,
  
  manager: ember.inject.service()

  teams:    ember.computed.reads 'manager.teams'
  team_set: ember.computed.reads 'manager.team_set'
  abstract: ember.computed.reads 'manager.abstract'

  has_selected_users: ember.computed.notEmpty 'selected_users'
  has_team_id:        ember.computed.notEmpty 'team_id'

  selected_users: null

  search_field: ''
  results: null

  init_base: ->
    @init_selected_users()
    @set_query_param()
    @init_team()

  init_selected_users: ->
    @set('selected_users', ember.makeArray())

  init_team: ->
    # if @get('has_team_id')
    #   team_id = @get('team_id')

    #   teams = @get('teams')
    #   team = teams.findBy 'id', team_id
    #   console.log('[INIT] team found as ', team)
    true

  find_unassigned: (users) ->
    unless ember.isPresent(users)
      @set('results', null)
      return

    abstract = @get('abstract')
    unassigned_users = abstract.users.filter (user) -> user.team_id == null
    user_ids = users.map (user) -> parseInt(user.get('id'))
    unassigned_results = @where_in(unassigned_users, 'id', user_ids)
    unassigned_results

  remove_selected: (users) ->
    return unless ember.isPresent(users)
    selected_users = @get('selected_users')
    non_selected = users.filter (user) -> !selected_users.contains(user)
    non_selected

  process_create_team: ->
    selected_users = @get('selected_users')
    manager        = @get('manager')

    console.log('selected_users are ', selected_users)

    options = {}
    options.users = selected_users

    manager.create_team(options).then (team) =>
      @get_app_route().transitionTo({queryParams: {team_id: team.id}}).then =>
        @set_query_param()

  set_query_param: -> @set('team_id', @get_query_param('team_id'))

  actions:
    search_results: (users) ->
      return unless ember.isPresent(users)
      unassigned_users   = @find_unassigned(users)
      non_selected_users = @remove_selected(unassigned_users)
      @set('results', non_selected_users)

    select_user: (user) ->
      return unless ember.isPresent(user)
      selected_users = @get('selected_users')
      if selected_users.contains(user)
        selected_users.removeObject(user)
      else
        selected_users.pushObject(user)
      updated_users = @remove_selected(@get('results'))
      @set('results', updated_users)

    create_team: ->
      @process_create_team()