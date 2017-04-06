import ember       from 'ember'
import totem_scope from 'totem/scope'
import tc          from 'totem/cache'
import ta          from 'totem/ds/associations'
import tm          from 'totem-messages/messages'

###
# # qualitative.coffee
- Type: **Mixin*
- Package: **thinkspace-peer-assessment-pe**
###
export default ember.Mixin.create
  # ### Properties
  valid_qual_sections: null

  # ### Computed properties
  has_qualitative_section: ember.computed.notEmpty 'model.qualitative_items'

  # ### Observers
  qual_section_error_observer: ember.observer 'is_confirmation', 'reviews.@each.value', ->  @process_reviews_errors()

  # ### Helpers
  process_reviews_errors: ->
    return unless @get 'is_confirmation'
    assessment        = @get 'model'
    qualitative_items = assessment.get 'qualitative_items'
    unless ember.isPresent(qualitative_items)
      @reset_required_comments_error() # There are no qualitative items, do not require.
      return
    count      = qualitative_items.get 'length'
    reviews    = @get 'reviews'
    has_errors = false
    reviews.forEach (review) =>
      valid_count = review.valid_qualitative_items_count()
      has_errors = true unless ember.isEqual(valid_count, count)
    if has_errors then @set_required_comments_error() else @reset_required_comments_error()

  set_required_comments_error:   -> @set 'valid_qual_sections', null
  reset_required_comments_error: -> @set 'valid_qual_sections', true

  changeset_valid_qual: ember.observer 'valid_qual_sections', ->
    if ember.isPresent(@get('changeset'))
      @set_changeset_valid_qual()

  set_changeset_valid_qual: ->
    if ember.isPresent(@get('changeset'))
      @get('changeset').set('valid_qual_sections', @get('valid_qual_sections'))
