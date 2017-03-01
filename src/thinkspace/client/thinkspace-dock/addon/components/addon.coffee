import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName: ''

  active: ember.computed.bool 'addon.active'

  actions:
    select: -> @get('addons').toggle_addon @get('addon'); return

  # # ### TESTING ONLY
  # init_base: ->
  #   @send 'select' if @addon.engine == 'thinkspace-resource'
