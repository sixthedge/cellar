import ember from 'ember'
import ta from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.polymorphic 'ownerable'
    ta.belongs_to  'lab:result', reads: {}
  ),

  attempts:       ta.attr('number')
  state:          ta.attr('string')
  all_correct:    ta.attr('boolean')
  value:          ta.attr()
  detail:         ta.attr()
  ownerable_type: ta.attr('string')
  ownerable_id:   ta.attr('number')

  locked: ember.computed.equal 'state', 'locked'

  # didCreate: -> @didLoad()
  #
  # didLoad: ->
  #   @get(ta.to_p 'lab:result').then (result) =>
  #     result.get(ta.to_p 'lab:observations').then (observations) =>
  #       observations.pushObject(@)  unless observations.includes(@)
