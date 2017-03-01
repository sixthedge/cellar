import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.has_many   'wf:assessments'
  ), 

  location: ta.attr('string')
