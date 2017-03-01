import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.belongs_to 'wf:forecast'
    ta.belongs_to 'wf:assessment_item'
  ),

  assessment_item_id:      ta.attr('number')
  input_value:             ta.attr()
  response_score_metadata: ta.attr()

  actual:      ember.computed.reads 'response_score_metadata.var_actual.actual'
  logic:       ember.computed.reads 'response_score_metadata.var_actual.logic'
  is_correct:  ember.computed.bool  'response_score_metadata.is_correct'
  has_score:   ember.computed.bool  'actual'

  id_is_correct: (id) -> ember.makeArray(@get 'actual').contains(id)

  set_associations: (forecast, assessment_item) ->
    @set ta.to_p('wf:forecast'), forecast
    @set ta.to_p('wf:assessment_item'), assessment_item
    @set 'assessment_item_id', parseInt(assessment_item.get 'id')
