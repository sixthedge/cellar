import ember from 'ember'
import util  from 'totem/util'
import ta    from 'totem/ds/associations'
import ns from 'totem/ns'

export default ta.Model.extend ta.add(
    ta.has_many    'tbl:review_sets', reads: {}
    ta.belongs_to  'tbl:assessment'
    ta.belongs_to  'team', reads: {}
  ),

  ownerable_id:     ta.attr('number')
  ownerable_string: ta.attr('string')
  state:            ta.attr('string')
  team_id:          ta.attr('number') # Used in filtering.

  is_approved:     ember.computed.equal 'state', 'approved'
  is_sent:         ember.computed.equal 'state', 'sent'
  is_not_approved: ember.computed.not   'is_approved'
  is_not_sent:     ember.computed.not   'is_sent'
  is_approvable:   ember.computed.and   'is_not_approved', 'is_not_sent'