import ember from 'ember'
import util  from 'totem/util'
import ta    from 'totem/ds/associations'
import ns from 'totem/ns'

export default ta.Model.extend ta.add(
    ta.polymorphic 'ownerable'
    ta.has_many    'tbl:reviews', reads: {}
    ta.belongs_to  'tbl:team_set', reads: {}
  ),

  # ### Attributes
  ownerable_id:     ta.attr('number')
  ownerable_string: ta.attr('string')
  state:            ta.attr('string')
  team_set_id:      ta.attr('number')
  status:           ta.attr('string')
  
  # ### State Properties
  is_sent:         ember.computed.equal 'state', 'sent'
  is_ignored:      ember.computed.equal 'state', 'ignored'
  is_not_ignored:  ember.computed.not 'is_ignored'
  is_not_sent:     ember.computed.not 'is_sent'
  is_approvable:   ember.computed.and 'is_not_approved', 'is_not_sent'
  is_submitted:    ember.computed.equal 'state', 'submitted'
  is_read_only:    ember.computed 'is_approved', 'is_submitted', -> @get('is_approved') or @get('is_submitted')

  # ### Status Properties
  is_complete:     ember.computed.equal 'status', 'complete'
  is_not_complete: ember.computed.not 'is_complete'