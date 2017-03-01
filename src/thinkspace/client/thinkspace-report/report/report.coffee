import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.has_many  'report:file', reads: {}
  ),

  token:      ta.attr('string')
  title:      ta.attr('string')
  created_at: ta.attr('date')
