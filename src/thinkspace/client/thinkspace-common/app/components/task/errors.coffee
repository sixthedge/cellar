import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend

  changesets: ember.computed 'model', 'model.@each', ->
    model = @get('model')
    return model if ember.isArray(model)
    return ember.makeArray(model)

  has_errors: ember.computed 'changesets.@each.has_errors', ->
    changesets = @get('changesets')
    return false if ember.isEmpty changesets
    changesets.any (changeset) -> 
      return false unless ember.isPresent(changeset)
      changeset.get('has_errors')

  show: ember.computed.sum 'has_errors'