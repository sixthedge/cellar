import ember          from 'ember'
import ns             from 'totem/ns'
import base_component from 'thinkspace-base/components/base'
import abstract_init  from 'thinkspace-team-builder/mixins/abstract_init'


export default base_component.extend abstract_init,

  teams: ember.computed.reads 'team_set.scaffold.teams'

  search_field: ''

  selected_users: []

  init_base: ->
    @init_team_set().then (team_set) =>
      @init_abstract().then =>
        @set_all_data_loaded()

  actions:
    search_results: (val) ->
      @set('results', val)

    select_user: (user) ->
      if @get('selected_users').contains(user)
        @get('selected_users').removeObject(user)
      else
        @get('selected_users').pushObject(user)
