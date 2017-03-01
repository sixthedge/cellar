import ember from 'ember'

export default ember.Controller.extend
  init: ->
    @_super()
    @init_base()

  init_base: -> return