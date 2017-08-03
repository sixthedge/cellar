import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.belongs_to  'report:report'
  ), 

  title:                 ta.attr('string')
  url:                   ta.attr('string')
  content_type:          ta.attr('string')
  size:                  ta.attr('number')
  attachment_updated_at: ta.attr('date')