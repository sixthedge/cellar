import ember from 'ember'

export default ember.Mixin.create

  reset_all: ->
    @reset_models()

  toString: -> 'ThinkspaceService'
