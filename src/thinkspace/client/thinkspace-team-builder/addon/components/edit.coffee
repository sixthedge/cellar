import ember          from 'ember'
import ns             from 'totem/ns'
import base_component from 'thinkspace-base/components/base'
import abstract_init  from 'thinkspace-team-builder/mixins/abstract_init'
import arr_helpers    from 'thinkspace-common/mixins/helpers/common/array'
import util           from 'totem/util'

export default base_component.extend arr_helpers,

  manager: ember.inject.service()

  teams:     ember.computed.reads 'manager.teams'
  team_set:  ember.computed.reads 'manager.team_set'
  abstract:  ember.computed.reads 'manager.abstract'
  transform: ember.computed.reads 'team_set.transform'

  ## Re-initializes the team object when the manager transitions from being scaffold- to transform-driven
  refresh_team: ember.observer 'teams', ->
    @init_team()

  init_base: ->
    @init_team()
    @init_team_users()
    @init_unassigned_users()
    @set_all_data_loaded()

  init_team: ->
    teams   = @get('teams')
    team_id = @get_query_param('team_id')
    team    = teams.findBy('id', parseInt(team_id))
    @set('team', team)

  init_team_users: ->
    team     = @get('team')
    abstract = @get('abstract')
    users = @where_in(abstract.users, 'id', team.user_ids)

    @set('team_users', users)

  init_unassigned_users: ->
    abstract = @get('abstract')

    users = abstract.users.filter (user) -> ember.isEmpty(user.team_id)

    @set('unassigned_users', users)

  refresh: ->
    @init_team_users()
    @init_unassigned_users()

  actions:
    add_user: (user) ->
      console.log('calling add_user ', user)
      team = @get('team')
      manager = @get('manager')

      manager.add_to_team(team.id, user)
      @refresh()


    remove_user: (user) ->
      team = @get('team')
      manager = @get('manager')
      manager.remove_from_team(team.id, user)

      console.log('calling remove_user ', user)
      @refresh()

    save: ->
      @get('manager').save_transform()

    explode: ->
      params =
        id: @get('team_set.id')

      options =
        action: 'explode'
        verb:   'PUT'

      @tc.query_action(ns.to_p('team_set'), params, options).then (new_dawn) =>
        console.log('A NEW DAY DAWNS ', new_dawn)