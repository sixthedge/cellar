import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  manager: ember.inject.service()

  model:    null
  abstract: null

  user_ids: ember.computed.reads 'model.user_ids'
  count:    ember.computed.reads 'user_ids.length'

  actions:
    delete: ->
      @get('manager').remove_team_from_transform(@get('model'))