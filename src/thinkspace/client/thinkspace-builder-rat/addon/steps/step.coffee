import ember           from 'ember'
import base            from 'thinkspace-base/objects/base'
import common_helper   from 'thinkspace-common/mixins/helpers/common/all'

###
# # step.coffee
- Type: **Step Object**
- Package: **ethinkspace-builder-rat**
###
export default ember.Object.extend common_helper,

  loading: null
  set_loading:      (type) -> @set("loading.#{type}", true)
  reset_loading:    (type) -> @set("loading.#{type}", false)

  init: ->
    @_super()
    @set('loading', new Object)