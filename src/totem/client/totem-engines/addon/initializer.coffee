# Register/inject modules.
import ember from 'ember'
import ts    from 'totem/scope'
import te    from 'totem/error'
import tc    from 'totem/cache'
import tm    from 'totem-messages/messages'

class EngineInitializer

  initialize: (app) ->

    # totem/error
    app.register('totem:error', new te, instantiate: false)
    app.inject('route', 'totem_error', 'totem:error')
    app.inject('component', 'totem_error', 'totem:error')

    # totem/scope
    app.register('totem:scope', ts, instantiate: false)
    app.inject('route', 'totem_scope', 'totem:scope')
    app.inject('component', 'totem_scope', 'totem:scope')
    app.inject('service', 'totem_scope', 'totem:scope')

    # totem/cache
    app.register('totem:cache', tc, instantiate: false)
    app.inject('route', 'tc', 'totem:cache')
    app.inject('component', 'tc', 'totem:cache')

    # totem/messages
    app.register('totem:messages', tm, instantiate: false)
    app.inject('route', 'totem_messages', 'totem:messages')
    app.inject('component', 'totem_messages', 'totem:messages')

    # totem/scope service
    app.register('service:totem_scope', ts, instantiate: false)

export default new EngineInitializer
