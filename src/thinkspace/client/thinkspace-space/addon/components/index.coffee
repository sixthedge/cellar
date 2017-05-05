import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName: ''

  totem_data_config: ability: {ajax_source: ns.to_p('spaces')}, metadata: true

  all_spaces: ember.computed.reads 'model'
  