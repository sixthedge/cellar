import ember from 'ember'
import ns from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

###
# # team.coffee
- Type: **Component**
- Package: **thinkspace-peer-assessment-pe**
###
export default base_component.extend
  # ## Properties
  # ### Internal Properties
  selected_team_member: null
  manager:              null

  # ### Component Paths
  c_team_member: ns.to_p 'tbl:assessment', 'team', 'member'

  # ### Computed properties
  reviewables: ember.computed.reads 'manager.reviewables'
  reviewable:  ember.computed.reads 'manager.reviewable'

  # ## Actions
  actions:
    back:            ->
      manager = @get 'manager'
      manager.set_reviewable_from_offset(-1)
    next:            ->
      manager = @get 'manager'
      manager.set_reviewable_from_offset(1) 
    confirmation:    ->
      manager = @get 'manager'
      manager.set_confirmation()
