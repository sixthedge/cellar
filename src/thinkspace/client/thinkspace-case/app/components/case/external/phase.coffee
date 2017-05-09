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

  # ### Computed Properties
  phase_states: ember.computed ->
    phase = @get('model')
    if @pm.has_active_addons()
      @pmap.get_current_ownerable_phase_states(phase)
    else
      @pmap.get_current_user_phase_states(phase)

  # ## Events
  init_base: ->
    @pm   = @get('phase_manager')
    @pmap = @get('phase_manager.map')

