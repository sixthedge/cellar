import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.belongs_to  'wf:item'
    ta.has_many    'wf:assessments'
    ta.has_many    'wf:forecasts'
  ), 

  title:             ta.attr('string')
  description:       ta.attr('string')
  presentation:      ta.attr('string')
  item_header:       ta.attr('string')
  help_tip:          ta.attr()
