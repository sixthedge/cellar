import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  model:    null
  abstract: null

  user_ids: ember.computed.reads 'model.user_ids'