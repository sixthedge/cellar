import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/routes/base'

export default base.extend
  
  manager: ember.inject.service()

  model: (params) -> @tc.find_record_with_message ns.to_p('space'), params.space_id

  afterModel: (model) ->
    manager = @get('manager')
    manager.set_space(model)
    manager.initialize()