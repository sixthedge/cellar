import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.belongs_to  'indented:list', reads: {}
  ), 

  value: ta.attr()
