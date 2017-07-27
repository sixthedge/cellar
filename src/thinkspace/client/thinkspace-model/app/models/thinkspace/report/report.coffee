import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.has_many  'report:files', reads: {}
  ), 

  title:         ta.attr('string')
  created_at:    ta.attr('date')
  authable_type: ta.attr('string')
  authable_id:   ta.attr('string_id')
