import ember          from 'ember'
import ns             from 'totem/ns'
import base_component from 'thinkspace-base/components/base'
import abstract_init  from 'thinkspace-team-builder/mixins/abstract_init'
import arr_helpers    from 'thinkspace-common/mixins/helpers/common/array'
import util           from 'totem/util'

import student_row from 'thinkspace-team-builder/mixins/rows/student'

export default base_component.extend arr_helpers,

  manager: ember.inject.service()

  teams:     ember.computed.reads 'manager.teams'
  team_set:  ember.computed.reads 'manager.team_set'
  abstract:  ember.computed.reads 'manager.abstract'
  transform: ember.computed.reads 'team_set.transform'

  adding_members:            false

  ## Arrays of user rows that 
  selected_unassigned_user_rows: null
  selected_assigned_user_rows:   null

  init_base: ->
    @init_team()
    @init_team_users()
    @init_unassigned_users()
    @init_table_data()
    @set_all_data_loaded()

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

  init_team_users: ->
    team     = @get('team')
    abstract = @get('abstract')
    users    = @where_in(abstract.users, 'id', team.user_ids)
    @set('team_users', users)

  init_unassigned_users: ->
    abstract = @get('abstract')
    users    = abstract.users.filter (user) -> ember.isEmpty(user.team_id)
    @set('unassigned_users', users)

  refresh: ->
    @init_team()
    @init_team_users()
    @init_unassigned_users()
    @init_table_data()

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

  set_adding_members: -> @set('adding_members', true)

  reset_adding_members: -> 
    @set('selected_unassigned_user_rows', ember.makeArray())
    @set('adding_members', false)

  reset_selected_rows: (type) -> @set("selected_#{type}_user_rows", ember.makeArray())

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
      @get('manager').save_transform().then =>
        @get_app_route().transitionTo(ns.to_r('team_builder', 'manage'))

    select_color: (color) ->
      team = @get('team')
      ember.set(team, 'color', color.get('color'))

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
      console.log('calling cancel!!!')