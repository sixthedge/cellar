import ember from 'ember'
import util  from 'totem/util'
import ta    from 'totem/ds/associations'
import ns from 'totem/ns'

export default ta.Model.extend ta.add(
    ta.polymorphic 'ownerable'
    ta.has_many    'tbl:reviews', reads: {}
  ),

  ownerable_id:     ta.attr('number')
  ownerable_string: ta.attr('string')
  state:            ta.attr('string')
  
  is_sent:         ember.computed.equal 'state', 'sent'
  is_approved:     ember.computed.equal 'state', 'approved'
  is_not_approved: ember.computed.not 'is_approved'
  is_not_sent:     ember.computed.not 'is_sent'
  is_approvable:   ember.computed.and 'is_not_approved', 'is_not_sent'
  is_submitted:    ember.computed.equal 'state', 'submitted'
  is_read_only:    ember.computed 'is_approved', 'is_submitted', -> @get('is_approved') or @get('is_submitted')