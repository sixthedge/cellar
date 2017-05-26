import ember            from 'ember'
import ns               from 'totem/ns'
import column           from 'totem-table/table/column'
import base_component   from 'thinkspace-base/components/base'
import student_row      from 'thinkspace-team-builder/mixins/rows/student'
import selectable_mixin from 'thinkspace-common/mixins/table/cells/selectable'

export default base_component.extend selectable_mixin,
  
  # ### Services
  manager:  ember.inject.service()

  # ### Properties
  selected_team: null
  search_field: ''
  results:      []

  # ### Computed Properties
  teams:    ember.computed.reads 'manager.teams'
  team_set: ember.computed.reads 'manager.team_set'
  abstract: ember.computed.reads 'manager.abstract'
  users:    ember.computed.reads 'abstract.users'

  empty:    ember.computed.empty 'teams'

  has_selected_users:              ember.computed.notEmpty 'selected_rows'
  highlighted_users:               ember.computed 'results.@each', -> @get('results').mapBy('id')
  has_selected_assigned_users:     ember.computed.notEmpty 'selected_assigned_users'
  selected_assigned_users:         ember.computed.filterBy 'selected_rows', 'has_team'
  has_selected_all_assigned_users: ember.computed 'selected_rows.@each.has_team', ->
    @get('selected_rows').every (row) -> row.get('has_team')

  columns: ember.computed 'manager', 'model', ->
    [
      column.create({display: 'Select', component: '__table/cells/selectable', data: {calling: {component: @}}}),
      column.create({display: 'Last Name',  property: 'last_name'})
      column.create({display: 'First Name', property: 'first_name'}),
      column.create({display: 'Team', component: 'helpers/cells/team'}),
    ]

  # ### Initialization
  init_base: ->
    @set_loading 'all'
    @init_manager().then =>
      @init_table_data()
      @reset_loading 'all'

  init_manager: ->
    new ember.RSVP.Promise (resolve, reject) =>
      manager = @get('manager')
      model   = @get('model')
      manager.set_space(model)
      manager.initialize().then =>
        resolve()

  init_table_data: ->
    users   = @get('users')
    manager = @get('manager')
    rows    = @get_students()
    @set('rows', rows)

  # ### Helpers
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

  ## Needs to be called to ensure that changes to the transform are reflected
  refresh: -> @init_table_data()

  process_create_team: ->
    selected_users = @get('selected_rows')
    manager        = @get('manager')
    space          = manager.get('space')

    options = {}
    options.users = selected_users.mapBy 'model'

    @set_loading 'all'
    manager.create_team(options).then (team) =>
      @get_app_route().transitionTo(ns.to_r('team_builder', 'teams.builder'), space, {queryParams: {team_id: team.id}})
      @reset_loading 'all'

  goto_teams_edit: (team) ->
    space = @get('manager.space')
    @get_app_route().transitionTo ns.to_r('team_builder', 'teams.edit'), space, {queryParams: {team_id: team.id }}

  actions:
    add_to_team: (team) ->
      @set('selected_team', team)
      manager = @get('manager')
      @get('selected_rows').forEach (row) =>
        user = row.get('model')
        manager.add_to_team(team.id, user)
      manager.save_transform()

    remove_from_team: ->
      manager = @get('manager')
      @get('selected_rows').forEach (row) =>
        user    = row.get('model')
        team_id = row.get('team_id')
        manager.remove_from_team(team_id, user)
      manager.save_transform()

    create_team: ->
      @process_create_team()

    search_results: (val) -> 
      @set('results', val)

    explode: ->
      @set_loading 'all'
      @get('manager').explode().then =>
        @init_table_data()
        @reset_loading 'all'
        @totem_messages.api_success source: @, model: @get('team_set'), action: 'explode', i18n_path: ns.to_o('team_set', 'explode')
        , (error) => 
          totem_messages.api_failure error, source: @, model: @get('team_set'), action: 'explode'

    revert: ->
      @set_loading 'all'
      @get('manager').revert_transform().then =>
        @reset_loading 'all'
        @totem_messages.api_success source: @, model: @get('team_set'), action: 'revert', i18n_path: ns.to_o('team_set', 'revert')
        , (error) => 
          totem_messages.api_failure error, source: @, model: @get('team_set'), action: 'revert'
