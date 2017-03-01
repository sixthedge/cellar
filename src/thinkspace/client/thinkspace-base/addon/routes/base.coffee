import ember  from 'ember'
import auth   from 'totem-simple-auth/mixins/authenticated-route-mixin'

export default ember.Route.extend auth,

  session:    ember.inject.service()
  thinkspace: ember.inject.service()
  addons:     ember.inject.service()

  init: ->
    @_super()
    @session = @get('session')
    @init_base()

  init_base: -> return

  current_models: -> @get('thinkspace')
