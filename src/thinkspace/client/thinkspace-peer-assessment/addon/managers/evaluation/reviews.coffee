import ember       from 'ember'
import totem_scope from 'totem/scope'
import tc          from 'totem/cache'
import ta          from 'totem/ds/associations'
import tm          from 'totem-messages/messages'

###
# # reviews.coffee
- Type: **Mixin**
- Package: **thinkspace-peer-assessment**
# Helpers for the main evaluation manager to handle gets/sets/saves on a review.
###
export default ember.Mixin.create
  set_reviewable: (reviewable) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @save_review()
      @set 'reviewable', reviewable
      @set_review().then =>
        resolve()

  set_reviewable_from_offset: (offset) ->
    reviewables = @get 'reviewables'
    reviewable  = @get 'reviewable'
    return unless ember.isPresent(reviewables) and ember.isPresent(reviewable)
    index           = reviewables.indexOf(reviewable)
    return if index == -1
    new_index       = index + offset
    new_reviewable  = reviewables.objectAt(new_index)
    @set_reviewable(new_reviewable) if ember.isPresent(new_reviewable)
    @set_confirmation() if !ember.isPresent(new_reviewable) and offset == 1
    ember.run.scheduleOnce 'afterRender', => $('body').animate({scrollTop: 0}, 500)

  set_confirmation: ->
    @set_reviewable('confirmation')

  set_quantitative_value: (id, value) ->
    @get('review').set_quantitative_value(id, value)
    @points_expended_changed()

  set_quantitative_comment: (id, value) ->
    @get('review').set_quantitative_comment(id, value)
    @save_review()

  set_qualitative_value: (id, type, value) ->
    # This fires on every character change, so do not save unless initiated by the sub component.
    @get('review').set_qualitative_value(id, type, value)

  get_review_for_reviewable: (reviewable) ->
    reviews = @get 'reviews'
    reviewable_id       = parseInt reviewable.get('id')
    reviewable_class    = @totem_scope.standard_record_path(reviewable)
    review = reviews.find (item) => 
      item_class        = @totem_scope.standard_record_path item.get('reviewable_type')
      item_id           = parseInt item.get('reviewable_id')
      (reviewable_class == item_class) and (reviewable_id == item_id)

  points_expended_changed: -> @propertyDidChange 'points_expended'

  save_review: ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve() if @get('is_read_only') or @get('is_confirmation') or @get('is_review_read_only')
      model = @get 'review'
      model.save().then =>
        resolve()
      , (error) =>
       @totem_messages.api_failure error, source: @, model: model, action: 'update'
