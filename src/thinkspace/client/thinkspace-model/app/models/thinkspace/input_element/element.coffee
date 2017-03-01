import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.polymorphic 'helper_embedable'
    ta.has_many 'responses', reads: {filter: true, notify: true}
  ), 

  name:                  ta.attr('string')
  element_type:          ta.attr('string')
  helper_embedable_type: ta.attr('string')
  helper_embedable_id:   ta.attr('number')

  response: ember.computed.reads 'responses.firstObject'
