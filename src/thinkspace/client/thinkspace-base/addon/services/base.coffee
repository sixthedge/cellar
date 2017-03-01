import ember from 'ember'
import tc    from 'totem/cache'

export default ember.Service.extend

  session:    ember.inject.service()
  thinkspace: ember.inject.service()

  init: ->
    @_super()
    @tc = tc
    return unless @totem_scope
    @init_base()

  init_base: -> return

  current_models: -> @get('thinkspace')
