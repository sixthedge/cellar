import ember from 'ember'
import ta from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.belongs_to 'lab:category', reads: {}
    ta.has_many   'lab:observations', reads: {filter: true, notify: true}
  ), 

  title:    ta.attr('string')
  position: ta.attr('number')
  values:   ta.attr()
  value:    ta.attr()  # admin
  metadata: ta.attr()  # admin

  observation: ember.computed.reads 'observations.firstObject'
  description: ember.computed.reads 'values.description'
  html:        ember.computed -> @get('values.columns.result').htmlSafe()

  is_html:           ember.computed.equal 'values.type', 'html_result'
  admin_type:        ember.computed.reads 'value.type'
  admin_is_html:     ember.computed.equal 'value.type',  'html_result'
  admin_is_adjusted: ember.computed.equal 'value.type',  'adjusted_result'

  # Focusing
  is_focused:    false
  set_focused:   -> @set 'is_focused', true
  reset_focused: -> @set 'is_focused', false