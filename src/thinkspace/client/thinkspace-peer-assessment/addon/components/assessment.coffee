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
  
  # ### Components Paths
  c_item_quantitative: ns.to_p 'tbl:assessment', 'item', 'quantitative'
  c_item_qualitative:  ns.to_p 'tbl:assessment', 'item', 'qualitative'
  c_review_summary:    ns.to_p 'tbl:assessment', 'review', 'summary'
  c_loader:            ns.to_p 'common', 'loader'
  c_assessment:        ns.to_p 'tbl:assessment', 'type', 'base'

  # ## Events
  init: ->
    @_super()
    console.log('CALLING ASSESSMENT INIT')
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