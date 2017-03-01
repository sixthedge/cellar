import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.belongs_to  'ra:assessment'
    ta.belongs_to  'ra:status'
    ta.belongs_to  'ra:chat'
    ta.polymorphic 'ownerable'
  ), 

  answers:        ta.attr()
  justifications: ta.attr()
  userdata:       ta.attr()
  ownerable_id:   ta.attr('number')
  ownerable_type: ta.attr('string')
