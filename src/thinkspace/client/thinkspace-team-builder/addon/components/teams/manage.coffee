import ember          from 'ember'
import ns             from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  # ### Services
  manager: ember.inject.service()

  # ### Properties
  search_field: ''
  results:      []

  # ### Computed Properties
  highlighted_users: ember.computed 'results.@each', -> @get('results').mapBy('id')
  has_teams: ember.computed.reads 'manager.has_teams'

  init_base: ->
    @set_loading 'all'
    manager = @get('manager')
    model   = @get('model')
    manager.set_space(model)
    manager.initialize().then =>
      @reset_loading 'all'

  actions:
    toggle_view: -> @toggleProperty('on_teams'); false

    search_results: (val) -> 
      @set('results', val)

    explode: ->
      @set_loading 'all'
      @get('manager').explode().then =>
        @reset_loading 'all'
        @totem_messages.api_success source: @, model: @get('team_set'), action: 'explode', i18n_path: ns.to_o('team_set', 'explode')
        , (error) => 
          totem_messages.api_failure error, source: @, model: @get('team_set'), action: 'explode'

    revert: ->
      @set_loading 'all'
      @get('manager').revert_transform().then =>
        @reset_loading 'all'
        @totem_messages.api_success source: @, model: @get('team_set'), action: 'revert', i18n_path: ns.to_o('team_set', 'revert')
        , (error) => 
          totem_messages.api_failure error, source: @, model: @get('team_set'), action: 'revert'
