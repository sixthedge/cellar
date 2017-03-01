import ember from 'ember'
import ta    from 'totem/ds/associations'
import base  from '../common/componentable'

export default base.extend ta.add(
    ta.polymorphic 'authable'
    ta.belongs_to  'tbl:assessment', reads: { name: 'tbl:assessment' }
  ),

  authable_type: ta.attr('string')
  authable_id:   ta.attr('number')
  assessment_id: ta.attr('number')