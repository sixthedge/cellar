import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ta.Model.extend
  authable_id:    ta.attr('number')
  authable_type:  ta.attr('string')
  ownerable_id:   ta.attr('number')
  ownerable_type: ta.attr('string')
  room:           ta.attr('string')
  event:          ta.attr('string')
  question_id:    ta.attr('string')
  value:          ta.attr()
