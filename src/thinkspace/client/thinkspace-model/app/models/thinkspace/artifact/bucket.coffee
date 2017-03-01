import ember from 'ember'
import ta    from 'totem/ds/associations'
import base  from '../common/componentable'

export default base.extend ta.add(
    ta.polymorphic 'authable'
    ta.has_many    'artifact:files', reads: {sort: 'title', filter: true, notify: true}
  ),

  user_id:       ta.attr('number')
  instructions:  ta.attr('string')
  authable_type: ta.attr('string')
  authable_id:   ta.attr('number')

  has_instructions: ember.computed.notEmpty 'instructions'

  edit_component: ta.to_p 'bucket', 'edit'
