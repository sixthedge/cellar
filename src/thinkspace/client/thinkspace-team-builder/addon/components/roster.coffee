import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  manager: ember.inject.service()

  teams:     ember.computed.reads 'manager.teams'
  team_set:  ember.computed.reads 'manager.team_set'
  abstract:  ember.computed.reads 'manager.abstract'
  users:     ember.computed.reads 'abstract.users'

  empty: ember.computed.empty 'teams'

  selected_users: ember.makeArray()

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

