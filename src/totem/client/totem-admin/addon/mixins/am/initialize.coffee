import ember  from 'ember'
import config from 'totem-config/config'
import util   from 'totem/util'
import tc     from 'totem-config/configs'
import tr     from 'totem-config/routes'
import te     from 'totem-engines/engines'

export default ember.Mixin.create

  ttz:    ember.inject.service()
  pubsub: ember.inject.service()
  i18n:   ember.inject.service()

  init: ->
    @_super(arguments...)
    @ttz    = @get('ttz')
    @pubsub = @get('pubsub')
    @i18n   = @get('i18n')
    @config = config
    @tc     = tc
    @tr     = tr
    @te     = te

  toString: -> 'TotemAdminService'
