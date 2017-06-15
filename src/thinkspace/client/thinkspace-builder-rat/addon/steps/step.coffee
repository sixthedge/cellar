import ember           from 'ember'
import base            from 'thinkspace-base/objects/base'
import common_helper   from 'thinkspace-common/mixins/helpers/common/all'

###
# # step.coffee
- Type: **Step Object**
- Package: **ethinkspace-builder-rat**
###
export default ember.Object.extend common_helper,

  manager_loaded: false
  loading:        null
  set_loading:    (type) -> @set("loading.#{type}", true)
  reset_loading:  (type) -> @set("loading.#{type}", false)

  init: ->
    @_super()
    @set('loading', new Object)
    @set_loading('all')

  initialize: ->
    new ember.RSVP.Promise (resolve, reject) =>
      resolve()

  manager_load_obs: ember.observer 'manager_loaded', ->
    if @get('manager_loaded') then @reset_loading('all')