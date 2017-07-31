import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # phase.coffee
- Type: **Component**
- Package: **thinkspace-case**
###
export default base.extend
  # ## Properties
  # ### View Properties
  tagName: ''

  # ### Services
  # - **thinkspace-common**
  #   - [phase_manager](http://totem-docs.herokuapp.com/api/cellar/thinkspace/client/thinkspace-common/app/services/phase_manager.html)
  phase_manager: ember.inject.service()

  phase_state:  ember.computed 'phase_states', ->
    phase_states = @get('phase_states')
    return [] unless phase_states
    phase_states.findBy('phase_id', parseInt(@get('model.id')))

  # ## Events
  init_base: ->
    @pm   = @get('phase_manager')
    @pmap = @get('phase_manager.map')

