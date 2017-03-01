import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.polymorphic 'authable'
    ta.belongs_to  'wf:station', reads: {}
    ta.has_many    'wf:assessment_items', reads: {}
    ta.has_many    'wf:forecasts', reads: [
      {name: 'forecasts_by_date',  filter: true, sort: 'forecast_at:desc'}
      # {name: 'forecasts_by_score', filter: true, sort: 'score:desc'}
    ]
  ), 

  title:         ta.attr('string')
  description:   ta.attr('string')
  authable_type: ta.attr('string')
  authable_id:   ta.attr('number')
