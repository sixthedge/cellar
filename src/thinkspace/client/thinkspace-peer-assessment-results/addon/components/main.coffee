import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # results.coffee
- Type: **Component**
- Package: **thinkspace-peer-assessment-results**
###
export default base.extend

  # ## Events
  init_base: ->
    model = @get('thinkspace').get_current_assignment()
    @set 'model', model