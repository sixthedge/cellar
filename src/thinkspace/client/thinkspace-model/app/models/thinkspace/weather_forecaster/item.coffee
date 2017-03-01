import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.has_many 'wf:assessment_items'
  ), 

  name:              ta.attr('string')
  title:             ta.attr('string')
  description:       ta.attr('string')
  presentation:      ta.attr('string')
  response_metadata: ta.attr()
  help_tip:          ta.attr()
