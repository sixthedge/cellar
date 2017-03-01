import ember from 'ember'
import util  from 'totem/util'

export default ember.Mixin.create

  ownerable_map: null

  error: (args...) -> util.error(@, args...)

  toString: -> 'PhaseManagerMap'
