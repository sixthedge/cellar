import ember from 'ember'
import base_component from 'thinkspace-base/components/base'

###
# # summary.coffee
- Type: **Component**
- Package: **thinkspace-peer-assessment**
###
export default base_component.extend
  # ## Properties
  # ### View Property
  tagName: 'li'
  classNames: ['thinkspace-pe-conf']

  # ### Internal Properties
  edit_team_member: 'edit_team_member'

  # ### Computed Properties
  expended_points:       ember.computed 'model', ->   @get('model').get_expended_points()
  positive_comments:     ember.computed 'model', ->   @get('model').get_positive_qualitative_comments()
  constructive_comments: ember.computed 'model', ->   @get('model').get_constructive_qualitative_comments() 

  assessment_qualitative_items: ember.computed 'assessment', -> @get('assessment.qualitative_items')
  qualitative_responses: ember.computed 'assessment_qualitative_items', ->
    items     = @get('assessment_qualitative_items')
    return [] unless ember.isPresent(items)
    review    = @get('model')
    ids       = items.mapBy('id')
    responses = []

    ids.forEach (id) =>
      val               = review.get_qualitative_value_for_id(id)
      label             = @get('assessment').get_qualitative_label_for_id(id)
      response          = {}
      response['id']    = id
      response['value'] = val
      response['label'] = label
      responses.pushObject(response)
    responses

  has_errors: ember.computed.equal 'quantitative_errors', false

  quantitative_errors: ember.computed 'qualitative_responses', ->
    responses = @get('qualitative_responses')
    i = 0
    responses.forEach (item) =>
      i += 1 if ember.isPresent(item.value)
    i == responses.get('length')

  assessment_quantitative_items: ember.computed 'assessment', -> @get('assessment.quantitative_items')
  category_responses:            ember.computed 'assessment_quantitative_items', ->
    items = @get 'assessment_quantitative_items'
    return [] unless ember.isPresent(items)
    review = @get 'model'
    ids    = items.mapBy('id')
    responses = []
    ids.forEach (id) =>
      value             = review.get_quantitative_value_for_id(id)
      label             = items.findBy('id', id).label
      response          = {}
      response['id']    = id
      response['value'] = value
      response['label'] = label
      responses.pushObject(response)
    responses

  actions:
    edit_team_member: -> 
      @get('model.reviewable').then (reviewable) =>
        @get('manager').set_reviewable reviewable