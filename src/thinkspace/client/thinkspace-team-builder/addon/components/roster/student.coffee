import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: 'tr'

  manager: ember.inject.service()

  teams:      ember.computed.reads 'manager.teams'
  team:       ember.computed 'model.team_id', -> @get('teams').findBy 'id', @get('model.team_id')
  team_title: ember.computed 'team.title', -> if ember.isPresent(@get('team')) then @get('team.title') else 'Unassigned'

  is_selected: ember.computed 'selected_users.@each', -> @get('selected_users').contains(@get('model'))

  click: -> @send 'toggle_select'

  actions:

    toggle_select: -> 
      action = if @get('is_selected') then 'deselect' else 'select'
      @sendAction action, @get('model')


