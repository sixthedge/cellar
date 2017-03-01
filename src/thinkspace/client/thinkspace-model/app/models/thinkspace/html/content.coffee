import ember from 'ember'
import ta    from 'totem/ds/associations'
import base  from '../common/componentable'

export default base.extend ta.add(
    ta.polymorphic 'authable'
    ta.has_many 'elements', reads: {name: 'input_elements'}
  ), 

  html_content:   ta.attr('string')
  abilities:      ta.attr()
  authable_type:  ta.attr('string')
  authable_id:    ta.attr('number')
