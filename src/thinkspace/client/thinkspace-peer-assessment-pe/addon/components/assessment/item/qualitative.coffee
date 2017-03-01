import ember from 'ember'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # Properties
  manager: null
  comment: null

  # ### Computed properties
  review:           ember.computed.reads 'manager.review'
  assessment:       ember.computed.reads 'manager.model'
  points_different: ember.computed.reads 'assessment.points_different'
  is_read_only:     ember.computed.or 'manager.is_read_only', 'manager.is_review_read_only'

  # Observers
  # TODO: Why won't just `review` work for the binding as it does in quantitative?
  review_change: ember.observer 'manager.review', -> @initialize_review()

  # Events
  init: ->
    @_super()
    model_id = @get('model.id')
    ember.defineProperty @, 'comment', ember.computed 'review', "review.value.qualitative.#{model_id}.value", ->
      review = @get('review')
      return unless ember.isPresent(review)
      value = review.get_qualitative_value_for_id(model_id)
      if ember.isPresent(value) then return value else return '' 

  # Helpers
  initialize_review: ->
    model_id = @get('model.id')
    comment  = @get('review').get_qualitative_value_for_id(model_id)
    @set('comment', comment)

  actions: 
    set_qualitative_value: (value) -> 
      @get('manager').set_qualitative_value @get('model.id'), @get('model.feedback_type'),  value
    save_review: -> @get('manager').save_review()