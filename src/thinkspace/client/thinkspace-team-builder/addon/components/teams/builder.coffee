import ember          from 'ember'
import ns             from 'totem/ns'
import column         from 'totem-table/table/column'
import base_component from 'thinkspace-base/components/base'
import arr_helpers    from 'thinkspace-common/mixins/helpers/common/array'
import student_row    from 'thinkspace-team-builder/mixins/rows/student'

export default base_component.extend arr_helpers,
  
  # ### Services
  manager: ember.inject.service()

  # ### Properties
  selected_users: null
  adding_members: false
  search_field:   ''
  results:        null
  rows:           null

  # ### Computed Properties
  teams:    ember.computed.reads 'manager.teams'
  team_set: ember.computed.reads 'manager.team_set'
  abstract: ember.computed.reads 'manager.abstract'

  team_title: ember.computed.reads 'team.title'

  has_teams:          ember.computed.notEmpty 'teams'
  has_selected_users: ember.computed.notEmpty 'selected_users'
  no_selected_users:  ember.computed.not 'has_selected_users'
  has_team_id:        ember.computed.notEmpty 'team_id'

  columns: ember.computed 'manager', 'model', ->
    columns = [
      column.create({display: 'First Name', property: 'first_name'}),
      column.create({display: 'Last Name', property: 'last_name'}),
      column.create({display: '', component: '__table/cells/delete', data: {calling: @}})
    ]

  # ### Initialization
  init_base: ->
    @set_loading 'all'
    @init_manager().then =>
      @set_query_param()
      @init_team()
      @init_selected_users()
      @init_table_data()
      @reset_loading 'all'

  init_manager: ->
    new ember.RSVP.Promise (resolve, reject) =>
      manager = @get('manager')
      model   = @get('model')
      manager.set_space(model)
      manager.initialize().then =>
        resolve()

  ## Now used to init row/student Ember Objects
  init_table_data: ->
    selected_users      = @get('selected_users')
    manager             = @get('manager')
    rows                = ember.makeArray()

    selected_users.forEach (user) =>
      row = student_row.create(model: user, manager: manager)
      rows.pushObject(row)

    @set('rows', rows)

  init_unassigned_users: ->
    abstract         = @get('abstract')
    selected_users   = @get('selected_users')
    unassigned_users = abstract.users.filter (user) -> user.team_id == null
    selected_users.forEach (user) =>
      if unassigned_users.contains(user)
        unassigned_users.removeObject(user)

    @set('unassigned_users', unassigned_users)

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
      team    = teams.findBy('id', parseInt(team_id))
      @set('team', team)
    else
      @set 'team', null

  # ### Helpers
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

    options.color = @get('selected_color.color')

    manager.create_team(options).then (team) =>
      @goto_team(team)

  set_query_param: -> @set('team_id', @get_query_param('team_id'))

  refresh: -> 
    @init_team_users()

  update_sorted: (sorted_users) ->
    @set('selected_users', sorted_users)

  delete_row: (opts) ->
    rows    = @get('rows')
    row     = opts.get_data('row')
    c_table = opts.get_component('table')

    @remove_user_from_team(row).then =>
      rows.removeObject(row) if rows.contains(row)
      @set('rows', rows)
      c_table.set('rows', rows)

  remove_user_from_team: (row) ->
    new ember.RSVP.Promise (resolve, reject) =>
      manager = @get('manager')
      team    = @get('team')

      manager.remove_from_team(team.id, row.get('model'))
      @save_transform().then =>
        resolve()

  ## Helper to ensure that we update any changes to the team before we use the manager to persist them.
  save_transform: ->
    new ember.RSVP.Promise (resolve, reject) =>
      manager    = @get('manager')
      team       = @get('team')
      team_title = @get('team_title')
      team_title = "New Team #{new Date()}" if ember.isEmpty(team_title)

      ember.set(team, 'title', team_title)
      ember.set(team, 'color', @get('selected_color.color'))

      manager.save_transform().then =>
        resolve()

  goto_team: (team) ->
    qp = {team_id: null}
    qp = {team_id: team.id} if ember.isPresent(team)
    @get_app_route().transitionTo(ns.to_r('team_builder', 'teams.builder'), @get('model'), {queryParams: qp}).then =>
      @set_query_param()
      @init_team()
      @init_table_data()
      @init_selected_users()

  goto_manage_route: ->
    @get_app_route().transitionTo(ns.to_r('team_builder', 'teams.manage'), @get('model'))

  goto_roster_route: ->
    @get_app_route().transitionTo(ns.to_r('team_builder', 'teams.roster'), @get('model'))

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

    add_to_team: (team) ->
      @set('selected_team', team)
      manager = @get('manager')
      @get('selected_users').forEach (user) =>
        manager.add_to_team(team.id, user)
      manager.save_transform()

    cancel: ->
      @get('manager').remove_team_from_transform(@get('team')).then =>
        @get_app_route().transitionTo(ns.to_r('team_builder', 'teams.manage'))

    remove_user: (user) ->
      team    = @get('team')
      manager = @get('manager')
      manager.remove_from_team(team.id, user)
      @refresh()

    add_members: ->
      @set('adding_members', true)
      false

    select_color: (color) -> @set('selected_color', color)

    finalize_team: ->
      @save_transform().then =>
        @goto_roster_route()
