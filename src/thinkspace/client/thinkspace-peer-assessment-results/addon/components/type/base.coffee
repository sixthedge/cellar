import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

###
# # results.coffee
- Type: **Component**
- Package: **thinkspace-peer-assessment-results**
###
export default base.extend
  # ## Properties

  # ### Internal Properties
  model:               null # Ember `tbl:overview` model
  calculated_overview: null # Server-generated anonymized overview object
  assessment:          null

  # ### Template Paths
  t_qualitative: ns.to_t 'tbl:overview', 'type', 'shared', 'qualitative'

  # ### Computed Properties
  has_comments:                          ember.computed.or 'has_qualitative_constructive_comments', 'has_qualitative_positive_comments'
  has_qualitative_positive_comments:     ember.computed.notEmpty 'calculated_overview.qualitative.positive'
  has_qualitative_constructive_comments: ember.computed.notEmpty 'calculated_overview.qualitative.constructive'
  
  assessment_quantitative_items: ember.computed 'assessment', -> @get('assessment.quantitative_items')
  categories:                    ember.computed 'assessment_quantitative_items', ->
    items = @get 'assessment_quantitative_items'
    return [] unless ember.isPresent(items)
    ids    = items.mapBy('id')
    responses = []
    ids.forEach (id) =>
      label             = items.findBy('id', id).label
      response          = {}
      response['id']    = id
      response['value'] = @get_calculated_overview_value_for_id(id)
      response['label'] = label
      responses.pushObject(response)
    responses

  overview_score: ember.computed 'calculated_overview.quantitative', ->
    overview = @get 'calculated_overview'
    return null unless ember.isPresent(overview)
    quantitative = ember.get(overview, 'quantitative')
    return 0 unless ember.isPresent(quantitative)
    for id, score of quantitative
      return score

  # ## Helpers
  get_calculated_overview_value_for_id: (id) ->
    calculated_overview = @get('calculated_overview')
    return null unless ember.isPresent(calculated_overview)
    quantitative = calculated_overview['quantitative']
    return null unless ember.isPresent(quantitative)
    id = parseInt(id)
    quantitative[id]