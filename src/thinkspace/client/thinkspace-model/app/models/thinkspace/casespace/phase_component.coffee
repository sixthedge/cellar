import ember from 'ember'
import ta from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.belongs_to  'component',       reads: {}
    ta.belongs_to  'phase',           reads: {}
    ta.polymorphic 'componentable'
  ),

  section:            ta.attr('string')
  component_id:       ta.attr('number')
  componentable_id:   ta.attr('number')
  componentable_type: ta.attr('string')
