import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

import student_row from 'thinkspace-team-builder/mixins/rows/student'

export default base_component.extend

  # ### Computed Properties
  manager: ember.inject.service()

  teams:     ember.computed.reads 'manager.teams'
  team_set:  ember.computed.reads 'manager.team_set'
  abstract:  ember.computed.reads 'manager.abstract'
  users:     ember.computed.reads 'abstract.users'

  empty: ember.computed.empty 'teams'

  selected_users: ember.makeArray()

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

  # ### Helpers
  init_base: ->
    @init_table_data()


  generate_dummy_model: ->
    obj            = {}
    obj.first_name = Math.random().toString(36).substring(7)
    obj.last_name  = Math.random().toString(36).substring(7)
    obj.team_id    = 1
    obj

  init_table_data: ->
    users   = @get('users')
    manager = @get('manager')
    rows = ember.makeArray()

    ## BULK TEST CASE
    # for i in [0..1000]
    #   row = student_row.create(model: @generate_dummy_model(), manager: manager)

    #   rows.pushObject(row)
    users.forEach (user) =>
      row = student_row.create(model: user, manager: manager)
      rows.pushObject(row)

    @set('rows', rows)

  goto_teams_edit: (team) ->
    space = @get('manager.space')
    @get_app_route().transitionTo 'edit', space, {queryParams: {team_id: team.id }}

  # ### Actions
  actions:

    select_user: (user) -> 
      @get('selected_users').pushObject(user) unless @get('selected_users').contains(user)

    deselect_user: (user) -> 
      @get('selected_users').removeObject(user)

    add_to_team: (team) ->
      manager = @get('manager')
      @get('selected_users').forEach (user) =>
        manager.add_to_team(team.id, user)
      manager.save_transform()

    create_team: ->
      manager = @get('manager')
      ids     = @get('selected_users').mapBy 'id'
      team    = manager.create_team(user_ids: ids)
      @goto_teams_edit(team)

