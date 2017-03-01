import ember from 'ember'
import ds from 'ember-data'
import ta from 'totem/ds/associations'

export default ta.Model.extend
  title:             ta.attr('string')
  description:       ta.attr('string')
  templateable_type: ta.attr('string')
  templateable_id:   ta.attr('number')
