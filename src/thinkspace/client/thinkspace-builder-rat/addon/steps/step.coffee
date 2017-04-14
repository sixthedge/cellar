import ember from 'ember'
import base  from 'thinkspace-base/objects/base'
import common_helper from 'thinkspace-common/mixins/helpers/common/all'

###
# # step.coffee
- Type: **Step Object**
- Package: **ethinkspace-builder-rat**
###
export default ember.Object.extend common_helper,

  all_data_loaded: false

  set_all_data_loaded: ->   
    @set('all_data_loaded', true)
  reset_all_data_loaded: -> 
    @set('all_data_loaded', false)