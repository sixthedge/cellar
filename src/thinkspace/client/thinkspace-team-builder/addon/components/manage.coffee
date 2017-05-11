import ember          from 'ember'
import ns             from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  # ### Services
  manager: ember.inject.service()

  # ### Properties
  is_manage:    true
  search_field: ''
  results:      []

  # ### Computed Properties
  highlighted_users: ember.computed 'results.@each', -> @get('results').mapBy('id')

  actions:
    toggle_view: -> @toggleProperty('on_teams'); false

    search_results: (val) -> 
      @set('results', val)

    explode: ->
      @get('manager').explode().then =>
        @set 'explode_success', true

    revert: ->
      @get('manager').revert_transform().then =>
        @set 'revert_success', true