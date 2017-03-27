import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  # ### Computed Properties
  manager: ember.inject.service()

  teams:     ember.computed.reads 'manager.teams'
  team_set:  ember.computed.reads 'manager.team_set'
  abstract:  ember.computed.reads 'manager.abstract'
  users:     ember.computed.reads 'abstract.users'

  empty: ember.computed.empty 'teams'

  selected_users: ember.makeArray()

  # ### Helpers
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

