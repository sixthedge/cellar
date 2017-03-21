import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

###
# # assessment.coffee
- Type: **Component**
- Package: **thinkspace-peer-assessment-instructor**
###
export default base_component.extend
  # ## Events
  init_base: ->
    model = @get('thinkspace').get_current_assignment()
    @set 'model', model