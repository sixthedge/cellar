import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  # ### Properties
  model:       null # PhaseState
  phase_score: null

  # ### Events
  init_base: ->
    model = @get 'model'
    model.get(ns.to_p('phase_score')).then (phase_score) => @set 'phase_score', phase_score
