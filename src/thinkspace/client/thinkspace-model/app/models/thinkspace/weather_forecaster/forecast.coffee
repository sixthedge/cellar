import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.polymorphic 'ownerable'
    ta.belongs_to  'wf:assessment'
    ta.has_many    'wf:responses'
  ),  

  is_locked:      ta.attr('boolean')
  state:          ta.attr('string')
  score:          ta.attr('number')
  forecast_at:    ta.attr('date')
  ownerable_type: ta.attr('string')
  ownerable_id:   ta.attr('number')

  completed: ember.computed.equal 'state', 'completed'
  locked:    ember.computed.equal 'state', 'locked'

  # Note: The forecast belongs to an ownerable, so all responses are for the ownerable.
  response_for_assessment_item: (assessment_item) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @get(ta.to_p 'wf:responses').then (responses) =>
        find_id = parseInt(assessment_item.get 'id')
        resolve responses.findBy 'assessment_item_id', find_id
