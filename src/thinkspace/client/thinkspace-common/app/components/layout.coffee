import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName:   ''

  top_pocket_is_expanded:   ember.computed.reads 'addons.top_pocket_is_expanded'
  right_pocket_is_expanded: ember.computed.reads 'addons.right_pocket_is_expanded'
  right_pocket_width_class: ember.computed.reads 'addons.right_pocket_width_class'
  dock_is_visible:          ember.computed.reads 'addons.dock_is_visible'
