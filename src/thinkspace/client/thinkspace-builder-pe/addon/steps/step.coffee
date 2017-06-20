import ember from 'ember'
import base  from 'thinkspace-base/objects/base'
import common_helper from 'thinkspace-common/mixins/helpers/common/all'

###
# # step.coffee
- Type: **Step Object**
- Package: **ethinkspace-builder-pe**
###
export default ember.Object.extend common_helper,

  builder: ember.inject.service()

  loading: null
  set_loading:      (type) -> @set("loading.#{type}", true)
  reset_loading:    (type) -> @set("loading.#{type}", false)

  init: ->
    @_super()
    @set('loading', new Object)
    @set_loading('all')
    @set('model', @get('builder').get_model())

  init_data: ->
    new ember.RSVP.Promise (resolve, reject) =>
      resolve()