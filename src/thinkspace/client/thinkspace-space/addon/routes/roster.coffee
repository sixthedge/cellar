import ember  from 'ember'
import ns     from 'totem/ns'
import base   from 'thinkspace-base/routes/base'

export default base.extend

  model:      (params) -> @tc.find_record_with_message ns.to_p('space'), params.space_id
  afterModel: (space) -> @current_models().set_current_models(space: space)
