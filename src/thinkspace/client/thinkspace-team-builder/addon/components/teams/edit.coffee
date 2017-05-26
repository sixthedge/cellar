import ember          from 'ember'
import ns             from 'totem/ns'
import base_component from 'thinkspace-base/components/base'
import abstract_init  from 'thinkspace-team-builder/mixins/abstract_init'
import arr_helpers    from 'thinkspace-common/mixins/helpers/common/array'
import util           from 'totem/util'

import student_row from 'thinkspace-team-builder/mixins/rows/student'

export default base_component.extend arr_helpers,

  # ### Services
  manager: ember.inject.service()

  # ### Properties
  adding_members: false
  ## Arrays of user rows that 
  selected_unassigned_user_rows: null
  selected_assigned_user_rows:   null

  # ### Computed Properties
  teams:       ember.computed.reads 'manager.teams'
  team_set:    ember.computed.reads 'manager.team_set'
  abstract:    ember.computed.reads 'manager.abstract'
  transform:   ember.computed.reads 'team_set.transform'
  teams_count: ember.computed.reads 'teams.length'
  team_title:  ember.computed.reads 'team.title'


  # ### Initialization
  init_base: ->
    @set_loading 'all'
    @init_manager().then =>
      @init_team()
      @init_team_image()
      @init_team_users()
      @init_unassigned_users()
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
    team_users       = @get('team_users')
    unassigned_users = @get('unassigned_users')
    manager          = @get('manager')

    team_rows = ember.makeArray()
    team_users.forEach (user) =>
      row = student_row.create(model: user, manager: manager)
      team_rows.pushObject(row)

    unassigned_rows = ember.makeArray()
    unassigned_users.forEach (user) =>
      row = student_row.create(model: user, manager: manager)
      unassigned_rows.pushObject(row)

    @set('team_rows', team_rows)
    @set('unassigned_rows', unassigned_rows)

  init_team: ->
    teams   = @get('teams')
    team_id = @get_query_param('team_id')
    team    = teams.findBy('id', parseInt(team_id))
    @set('team', team)

  ## Used to allow us to revert to the team's original state if user cancels edit
  init_team_image: ->
    team       = @get('team')
    team_image = JSON.parse(JSON.stringify(team))
    @set('team_state', team_image)

  init_team_users: ->
    team     = @get('team')
    abstract = @get('abstract')
    users    = @where_in(abstract.users, 'id', team.user_ids)
    @set('team_users', users)

  init_unassigned_users: ->
    abstract = @get('abstract')
    users    = abstract.users.filter (user) -> ember.isEmpty(user.team_id)
    @set('unassigned_users', users)

  # ### Helpers
  refresh: ->
    @init_team()
    @init_team_users()
    @init_unassigned_users()
    @init_table_data()

  refresh_table_data: ->
    assigned   = @get('assigned_table')
    unassigned = @get('unassigned_table')
    assigned.set_rows(@get('team_rows'))
    if ember.isPresent(unassigned)
      unassigned.set_rows(@get('unassigned_rows'))

  process_add_selected_users: ->
    manager   = @get('manager')
    team      = @get('team')
    user_rows = @get('selected_unassigned_user_rows')
    return unless ember.isPresent(user_rows)
    return unless ember.isPresent(team)
    user_rows.forEach (row) =>
      user = row.get('model')
      manager.add_to_team(team.id, user)

    manager.save_transform().then =>
      @reset_selected_rows('unassigned')
      @refresh()
      @refresh_table_data()

  process_remove_selected_users: ->
    manager   = @get('manager')
    team      = @get('team')
    user_rows = @get('selected_assigned_user_rows')
    return unless ember.isPresent(user_rows)
    return unless ember.isPresent(team)
    user_rows.forEach (row) =>
      user = row.get('model')
      manager.remove_from_team(team.id, user)

    manager.save_transform().then =>
      @reset_selected_rows('assigned')
      @refresh()
      @refresh_table_data()

  set_adding_members: -> @set('adding_members', true)

  reset_adding_members: -> 
    @set('selected_unassigned_user_rows', ember.makeArray())
    @set('adding_members', false)

  reset_selected_rows: (type) -> @set("selected_#{type}_user_rows", ember.makeArray())

  revert_team: -> 
    new ember.RSVP.Promise (resolve, reject) =>
      manager = @get('manager')
      manager.revert_team(@get('team.id'), @get('team_state'))
      manager.save_transform().then =>
        resolve()

  actions:
    add_user: (user) ->
      team    = @get('team')
      manager = @get('manager')
      manager.add_to_team(team.id, user)
      @refresh()

    remove_user: (user) ->
      team    = @get('team')
      manager = @get('manager')
      manager.remove_from_team(team.id, user)
      @refresh()

    save: ->
      team = @get('team')
      @get('manager').update_title_for_team(team, @get('team_title'))
      @get('manager').update_color_for_team(team, @get('selected_color.color'))
      @get('manager').save_transform().then =>
        @get_app_route().transitionTo(ns.to_r('team_builder', 'teams.manage'))

    select_color: (color) -> @set 'selected_color', color

    select_assigned: (opts) ->
      row      = opts.get_data('row')
      selected = @get('selected_assigned_user_rows') || ember.makeArray()
      if selected.contains(row)
        selected.removeObject(row)
      else
        selected.pushObject(row)
      @set('selected_assigned_user_rows', selected)

    select_unassigned: (opts) ->
      row      = opts.get_data('row')
      selected = @get('selected_unassigned_user_rows') || ember.makeArray()
      if selected.contains(row)
        selected.removeObject(row)
      else
        selected.pushObject(row)
      @set('selected_unassigned_user_rows', selected)

    register_assigned: (c_table) ->
      @set('assigned_table', c_table)

    register_unassigned: (c_table) ->
      @set('unassigned_table', c_table)

    set_add_members: ->
      @set_adding_members()
      false

    cancel_adding_members: ->
      @reset_adding_members()

    add_selected_users: ->
      @process_add_selected_users()

    remove_selected_users: ->
      @process_remove_selected_users()

    cancel: ->
      @revert_team().then =>
        @get_app_route().transitionTo(ns.to_r('team_builder', 'teams.manage'))