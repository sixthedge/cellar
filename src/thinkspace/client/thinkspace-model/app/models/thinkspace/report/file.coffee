import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.belongs_to  'report:report', reads: {}
  ),

  url:          ta.attr('string')
  title:        ta.attr('string')
  content_type: ta.attr('string')
  size:         ta.attr('number')
  created_at:   ta.attr('date')
