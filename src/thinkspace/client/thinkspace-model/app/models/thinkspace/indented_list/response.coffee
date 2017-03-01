import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.belongs_to  'indented:list', reads: {}
    ta.polymorphic 'ownerable'
  ),

  value:          ta.attr()
  ownerable_id:   ta.attr('number')
  ownerable_type: ta.attr('string')

  items: ember.computed.reads 'value.items'
