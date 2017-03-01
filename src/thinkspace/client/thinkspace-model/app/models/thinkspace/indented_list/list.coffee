import ember from 'ember'
import ta    from 'totem/ds/associations'
import base  from '../common/componentable'

export default base.extend ta.add(
    ta.has_many    'indented:responses', reads: {filter: true}
    ta.has_many    'indented:expert_responses'
    ta.polymorphic 'authable'
  ),

  title:         ta.attr('string')
  authable_id:   ta.attr('number')
  authable_type: ta.attr('string')
  expert:        ta.attr('boolean')
  settings:      ta.attr()

  # layout: ember.computed.reads 'settings.layout'
