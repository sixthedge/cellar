import ember  from 'ember'
import base   from 'thinkspace-base/components/base'
import m_dock from 'thinkspace-dock/mixins/main'

export default base.extend m_dock,

  resource_model:       ember.computed.reads 'thinkspace.current_model'
  can_manage_resources: ember.computed.bool  'resource_model.can.manage_resources'
  can_access_addon:     ember.computed.or    'resource_model.has_resources', 'can_manage_resources'

  addon_config:
    engine:          'thinkspace-resource'
    display:         'Resources'
    icon:            'tsi tsi-left tsi-tiny tsi-backpack_white'
    toggle_property: 'show_addon'
    right_pocket:    true
    init_width:      2
    group:           'first'

  show_addon: false
