import ember from 'ember'
import rad   from 'thinkspace-readiness-assurance-instructor/managers/rad'

export default ember.Mixin.create

  pubsub:        ember.inject.service()
  server_events: ember.inject.service()
  ttz:           ember.inject.service()

  init_base: ->
    @store         = @get('store')
    @ttz           = @get('ttz')
    @se            = @get('server_events')
    @messages      = @se.messages
    @pubsub        = @se.pubsub
    @pubsub_active = @se.pubsub.get('pubsub_active')
    @reset_data()
    @se.join_admin_room()

  rad: (options={}) ->
    options.am = @
    rad.create(options)

  reset: ->
    @reset_data()

  toString: -> 'ReadinessAssuranceAdminManager'
