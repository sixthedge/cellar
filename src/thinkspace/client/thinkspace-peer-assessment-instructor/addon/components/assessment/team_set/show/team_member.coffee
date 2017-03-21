import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

###
# # team_member.coffee
- Type: **Component**
- Package: **thinkspace-peer-assessment-instructor**
###
export default base_component.extend
  # ## Events
  init_base: -> 
    @init_ownerable()
    @set_all_data_loaded()

  click: -> @sendAction 'scroll_to', @get('model.id')

  # ## Helpers
  init_ownerable: ->
    ownerable = @get('team_members').findBy 'id', @get('model.ownerable_id').toString()
    @set 'ownerable', ownerable


