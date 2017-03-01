import ember from 'ember'
import ns from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # Properties
  selected_team_member: null
  manager:              null

  # ### Computed properties
  reviewables: ember.computed.reads 'manager.reviewables'
  reviewable:  ember.computed.reads 'manager.reviewable'

  # Components
  c_team_member: ns.to_p 'tbl:assessment', 'team', 'member'

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
