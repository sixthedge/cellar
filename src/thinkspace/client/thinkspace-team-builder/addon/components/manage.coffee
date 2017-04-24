import ember          from 'ember'
import ns             from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  manager: ember.inject.service()

  teams:    ember.computed.reads 'manager.teams'
  team_set: ember.computed.reads 'manager.team_set'
  abstract: ember.computed.reads 'manager.abstract'

  search_field: ''
  results:      null

  selected_users: []

  init_base: ->
    @set_all_data_loaded()

  actions:
    search_results: (val) ->
      @set('results', val)

    select_user: (user) ->
      if @get('selected_users').contains(user)
        @get('selected_users').removeObject(user)
      else
        @get('selected_users').pushObject(user)
