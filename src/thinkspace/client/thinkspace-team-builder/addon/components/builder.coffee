import ember          from 'ember'
import ns             from 'totem/ns'
import base_component from 'thinkspace-base/components/base'
import arr_helpers    from 'thinkspace-common/mixins/helpers/common/array'
import column         from 'thinkspace-common/table/column'

import student_row from 'thinkspace-team-builder/mixins/rows/student'

export default base_component.extend arr_helpers,
  
  manager: ember.inject.service()

  teams:    ember.computed.reads 'manager.teams'
  team_set: ember.computed.reads 'manager.team_set'
  abstract: ember.computed.reads 'manager.abstract'

  team_title: ember.computed.reads 'team.title'

  has_selected_users: ember.computed.notEmpty 'selected_users'
  has_team_id:        ember.computed.notEmpty 'team_id'

  selected_users: null
  adding_members: false

  search_field: ''
  results:      null
  rows:         null

  columns: ember.computed 'manager', 'model', ->
    columns = [
      column.create({display: 'First Name', property: 'first_name'}),
      column.create({display: 'Last Name', property: 'last_name'}),
      column.create({display: '', component: '__table/cells/delete', data: {calling: @}})
    ]

  init_base: ->
    @set_query_param()
    @init_team()
    @init_selected_users()
    #@init_unassigned_users()
    @init_table_data()
    @set_all_data_loaded()

  ## Now used to init row/student Ember Objects
  init_table_data: ->
    selected_users      = @get('selected_users')
    # unassigned_users    = @get('unassigned_users')
    manager             = @get('manager')
    rows                = ember.makeArray()
    # unassigned_students = ember.makeArray()

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

    console.log('[process_create_team] selected color is ', @get('selected_color'))

    options.color = @get('selected_color.color')

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

  delete_row: (opts) ->
    rows    = @get('rows')
    row     = opts.get_data('row')
    c_table = opts.get_component('table')

    @remove_user_from_team(row).then =>
      rows.removeObject(row) if rows.contains(row)
      @set('rows', rows)
      c_table.set('rows', rows)

  select_row: (opts) ->
    console.log('selecting', opts)

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

      team.title = team_title
      team.color = @get('selected_color.color')

      manager.save_transform().then =>
        resolve()

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
      @get('manager').remove_team_from_transform(@get('team')).then =>
        @get_app_route().transitionTo(ns.to_r('team_builder', 'manage'))

    remove_user: (user) ->
      team    = @get('team')
      manager = @get('manager')
      manager.remove_from_team(team.id, user)
      @refresh()

    add_members: ->
      console.log('calling adding_members')
      @set('adding_members', true)
      false

    select_color: (color) -> @set('selected_color', color)

    finalize_team: ->
      console.log('calling finalize_team!')
      @save_transform().then =>
        @get_app_route().transitionTo(ns.to_r('team_builder', 'manage'))
