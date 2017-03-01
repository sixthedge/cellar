import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName: ''

  # has_actions: ember.computed.or 'can.clone', 'can.destroy'

  # dropdown_collection: ember.computed ->
  #   collection = []
  #   collection.push {display: 'Clone Case',  route: @get('r_assignments_clone'),  model: @get('model')}  if @get('can.clone')
  #   collection.push {display: 'Delete Case', route: @get('r_assignments_delete'), model: @get('model')}  if @get('can.destroy')
  #   collection

  # c_dropdown_split_button: ns.to_p 'common', 'dropdown_split_button'
  # r_assignments_show:      ns.to_r 'assignments', 'show'
  # r_assignments_clone:     ns.to_r 'case_manager', 'assignments', 'clone'
  # r_assignments_delete:    ns.to_r 'case_manager', 'assignments', 'delete'
