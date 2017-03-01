import ember from 'ember'
import ds from 'ember-data'
import ta from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.belongs_to 'phase_state', reads: {}
  ), 

  score: ta.attr('number')
