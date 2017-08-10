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
  set_loading:      (type) -> @set("loading.#{type}", true); false
  reset_loading:    (type) -> @set("loading.#{type}", false); false

  set_all_data_loaded: -> @set 'all_data_loaded', true
  reset_all_data_loaded: -> @set 'all_data_loaded', false

  init: ->
    @_super()
    @set('loading', new Object)
    @set_loading('all')
    @set('model', @get('builder').get_model())

  init_data: ->
    new ember.RSVP.Promise (resolve, reject) =>
      resolve()

  manager_load_obs: ember.observer 'manager_loaded', ->
    if @get('manager_loaded') then @reset_loading('all')