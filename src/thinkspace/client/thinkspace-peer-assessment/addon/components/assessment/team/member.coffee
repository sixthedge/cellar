import ember from 'ember'
import ns from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

###
# # member.coffee
- Type: **Component**
- Package: **thinkspace-peer-assessment**
###
export default base_component.extend
  # ## Properties
  # ### View Properties
  tagName:           'li'
  classNames: ['otbl-basic-list_item', 'team-members_item']
  classNameBindings: ['is_selected:is-selected']

  # ### Internal Properties
  manager:    null
  reviewable: null
  review:     null

  # ### Computed properties
  is_selected: ember.computed 'model', 'reviewable', -> ember.isEqual @get('model'), @get('reviewable')
  is_balance:  ember.computed.reads 'manager.is_balance'

  points_expended: ember.computed 'review', 'manager.points_remaining', ->
    return unless @get('is_balance')
    review = @get 'review'
    review.get_expended_points()

  # ### Events
  init: ->
    @_super()
    model  = @get 'model'
    review = @get('manager').get_review_for_reviewable(model)
    @set 'review', review
  
  click: -> 
    manager = @get 'manager'
    manager.set_reviewable @get('model')
