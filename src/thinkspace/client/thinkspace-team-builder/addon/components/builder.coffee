import ember          from 'ember'
import ns             from 'totem/ns'
import base_component from 'thinkspace-base/components/base'
import arr_helpers    from 'thinkspace-common/mixins/helpers/common/array'

import student_row from 'thinkspace-team-builder/mixins/rows/student'

export default base_component.extend arr_helpers, roster_table,
  
  manager: ember.inject.service()

  teams:    ember.computed.reads 'manager.teams'
  team_set: ember.computed.reads 'manager.team_set'
  abstract: ember.computed.reads 'manager.abstract'

  team_title: ''

  has_selected_users: ember.computed.notEmpty 'selected_users'
  has_team_id:        ember.computed.notEmpty 'team_id'

  selected_users: null

  search_field: ''
  results: null

  table_config: [
    {
      display:   'Last name'
      property: 'last_name'
    },
    {
      display:   'First name'
      property: 'first_name'
    },
    {
      display: 'Team'
      property: 'computed_title'
    }
  ]

  init_base: ->
    @set_query_param()
    @init_team()
    @init_selected_users()
    @set_all_data_loaded()
    @init_table_data()

  ## Now used to init row/student Ember Objects
  init_table_data: ->
    selected_users = @get('selected_users')
    manager = @get('manager')
    rows = ember.makeArray()
    selected_users.forEach (user) =>
      row = student_row.create(model: user, manager: manager)

      rows.pushObject(row)

    console.log('rows are ', rows)

    @set('rows', rows)



  init_selected_users: ->
    if ember.isPresent(@get('team'))
      @set('selected_users', @init_team_users())
    else
      @set('selected_users', ember.makeArray())

  init_team_users: ->
    team     = @get('team')
    abstract = @get('abstract')
    users    = @where_in(abstract.users, 'id', team.user_ids)
    users

  init_team: ->
    if @get('has_team_id')
      teams   = @get('teams')
      team_id = @get('team_id')
      console.log('teams are ', teams)
      console.log('team_id is ', team_id)

      team    = teams.findBy('id', parseInt(team_id))
      console.log('team is ', team)
      @set('team', team)

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

    options = {}
    options.users = selected_users
    options.title = @get('team_title')

    manager.create_team(options).then (team) =>
      @get_app_route().transitionTo({queryParams: {team_id: team.id}}).then =>
        @set_query_param()
        @init_team()
        @init_table_data()

  set_query_param: -> @set('team_id', @get_query_param('team_id'))

  refresh: -> 
    @init_team_users()

  update_sorted: (sorted_users) ->
    @set('selected_users', sorted_users)

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

    cancel: ->
      @get('manager').remove_team_from_selected

    remove_user: (user) ->
      team    = @get('team')
      manager = @get('manager')
      manager.remove_from_team(team.id, user)
      @refresh()