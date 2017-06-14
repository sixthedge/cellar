import ember          from 'ember'
import ns             from 'totem/ns'
import base_component from 'thinkspace-base/components/base'
import eval_manager   from 'thinkspace-peer-assessment/managers/evaluation'

###
# # assessment.coffee
- Type: **Component**
- Package: **thinkspace-peer-assessment**
###
export default base_component.extend
  # ## Properties
  # ### View Properties
  classNames:       ['ts-componentable']
  has_team_members: true

  # ## Events
  init: ->
    @_super()
    @set_manager().then => @set_all_data_loaded()

  # ## Helpers
  set_manager: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model   = @get 'model'
      manager = eval_manager.create
        container: @container
        component: @
        model:     model

      manager.set_user_data().then =>
        @set 'manager', manager
        resolve()
      , (error) =>
        @set 'has_team_members', false
    , (error) => 
      @error(error)