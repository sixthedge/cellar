import ember from 'ember'
import ta from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.belongs_to 'observation', reads: {}
  ),

  value: ta.attr 'string'

  # didCreate: -> @didLoad()
  #
  # didLoad: ->
  #   @get(ta.to_p('observation')).then (observation) =>
  #     observation.get(ta.to_p('observation_notes')).then (notes) =>
  #       notes.pushObject(@) unless notes.includes(@)
  #   @_super()
