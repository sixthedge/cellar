import ember          from 'ember'
import ta             from 'totem/ds/associations'
import base_component from 'thinkspace-base/components/base'

###
# # base.coffee
- Type: **Component**
- Package: **thinkspace-peer-assessment-pe**
###
export default base_component.extend
  # ## Properties
  # ### Internal Properties
  manager:          null # managers/evaluation
  
  # ### Computed properties
  model:       ember.computed.reads 'manager.model'
  review:      ember.computed.reads 'manager.review'
  reviews:     ember.computed.reads 'manager.reviews'
  reviewable:  ember.computed.reads 'manager.reviewable'
  reviewables: ember.computed.reads 'manager.reviewables'

  points_total:     ember.computed.reads 'manager.points_total'
  points_expended:  ember.computed.reads 'manager.points_expended'
  points_remaining: ember.computed.reads 'manager.points_remaining'

  is_confirmation: ember.computed.reads 'manager.is_confirmation'
  is_balance:      ember.computed.reads 'manager.is_balance'
  is_read_only:    ember.computed.reads 'manager.is_read_only'
  is_disabled:     ember.computed.reads 'manager.is_disabled'

  has_errors:                    ember.computed.reads 'manager.has_errors'
  has_negative_points_remaining: ember.computed.reads 'manager.has_negative_points_remaining'
  has_qualitative_section:       ember.computed.reads 'manager.has_qualitative_section'
  has_points_different_rule:     ember.computed.reads 'manager.has_points_different_rule'
  has_points_remaining_rule:     ember.computed.reads 'manager.has_points_remaining_rule'

  errors: ember.computed.reads 'manager.errors'

  # ### Component Paths
  c_item_quantitative: ta.to_p 'tbl:assessment', 'item', 'quantitative'
  c_item_qualitative:  ta.to_p 'tbl:assessment', 'item', 'qualitative'
  c_team:              ta.to_p 'tbl:assessment', 'team'
  c_review_summary:    ta.to_p 'tbl:assessment', 'review', 'summary'

  # ## Actions
  actions:
    next:         -> @get('manager').set_reviewable_from_offset(1)
    previous:     -> @get('manager').set_reviewable_from_offset(-1)
    confirmation: -> @get('manager').set_confirmation()
    submit:       -> @get('manager').submit()