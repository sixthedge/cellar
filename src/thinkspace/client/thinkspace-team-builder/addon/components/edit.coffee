import ember          from 'ember'
import ns             from 'totem/ns'
import base_component from 'thinkspace-base/components/base'
import abstract_init  from 'thinkspace-team-builder/mixins/abstract_init'

export default base_component.extend abstract_init,

  teams: ember.computed.reads 'team_set.scaffold.teams'

  init_base: ->
    @init_team_set().then (team_set) =>
      @init_abstract().then =>
        @init_team()
        @set_all_data_loaded()

  init_team: ->
    teams   = @get('teams')
    team_id = @get_query_param('team_id')

    console.log('teams are ', teams, team_id)

    team = teams.findBy('id', parseInt(team_id))
    console.log('found team ', team)

    @set('team', team)