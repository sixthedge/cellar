import ember            from 'ember'
import ns               from 'totem/ns'
import column           from 'totem-table/table/column'
import base_component   from 'thinkspace-base/components/base'
import student_row      from 'thinkspace-team-builder/mixins/rows/student'
import selectable_mixin from 'thinkspace-common/mixins/table/cells/selectable'

export default base_component.extend selectable_mixin,

  # ### Computed Properties
  manager:  ember.inject.service()

  teams:    ember.computed.reads 'manager.teams'
  team_set: ember.computed.reads 'manager.team_set'
  abstract: ember.computed.reads 'manager.abstract'
  users:    ember.computed.reads 'abstract.users'

  empty:    ember.computed.empty 'teams'

  has_selected_users: ember.computed.notEmpty 'selected_rows'

  selected_team: null
  
  columns: ember.computed 'manager', 'model', ->
    [
      column.create({display: 'Select', component: '__table/cells/selectable', data: {calling: {component: @}}}),
      column.create({display: 'Last Name',  property: 'last_name'})
      column.create({display: 'First Name', property: 'first_name'}),
      column.create({display: 'Team', component: 'helpers/cells/team'}),
    ]

  # ### Helpers
  init_base: ->
    @init_table_data()
    @set_all_data_loaded()

  generate_dummy_model: ->
    obj            = {}
    obj.first_name = Math.random().toString(36).substring(7)
    obj.last_name  = Math.random().toString(36).substring(7)
    obj.team_id    = 1
    obj

  get_test_students: ->
    rows    = []
    manager = @get('manager')
    for i in [0..1000]
      row = student_row.create(model: @generate_dummy_model(), manager: manager)
      rows.pushObject(row)
    rows

  get_students: ->
    rows    = []
    users   = @get('users')
    manager = @get('manager')
    users.forEach (user) =>
      row = student_row.create(model: user, manager: manager)
      rows.pushObject(row)
    rows

  init_table_data: ->
    users   = @get('users')
    manager = @get('manager')
    #rows    = @get_test_students()
    rows    = @get_students()
    @set('rows', rows)

  ## Needs to be called to ensure that changes to the transform are reflected
  refresh: -> @init_table_data()

  goto_teams_edit: (team) ->
    space = @get('manager.space')
    @get_app_route().transitionTo 'edit', space, {queryParams: {team_id: team.id }}

  process_create_team: ->
    selected_users = @get('selected_rows')
    manager        = @get('manager')
    space          = manager.get('space')

    options = {}
    options.users = selected_users.mapBy 'model'

    manager.create_team(options).then (team) =>
      @get_app_route().transitionTo(ns.to_r('team_builder', 'builder'), space, {queryParams: {team_id: team.id}})

  actions:
    add_to_team: (team) ->
      @set('selected_team', team)
      manager = @get('manager')
      @get('selected_rows').forEach (row) =>
        user = row.get('model')
        manager.add_to_team(team.id, user)
      manager.save_transform().then =>
        #manager.reconcile_assigned_users()
        @refresh()

    create_team: ->
      @process_create_team()

      # manager = @get('manager')
      # ids     = @get('selected_users').mapBy 'id'
      # team    = manager.create_team(user_ids: ids)
      # @goto_teams_edit(team)
