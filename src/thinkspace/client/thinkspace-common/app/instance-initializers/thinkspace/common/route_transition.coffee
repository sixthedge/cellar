import ember from 'ember'

initializer =
  name: 'thinkspace-common-tracker'
  initialize: (instance) ->

    router = instance.lookup('router:main')

    router.reopen

      server_events: ember.inject.service()

      route_transition: (->
        route = @get('currentRouteName')
        @get('server_events').transition_to_route(route)
      ).on('didTransition')

export default initializer
