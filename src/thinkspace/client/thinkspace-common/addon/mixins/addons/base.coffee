import ember from 'ember'
# Mixins to build service.
import m_addons       from './addons'
import m_config       from './config'
import m_dock         from './dock'
import m_initialize   from './initialize'
import m_top_pocket   from './top_pocket'
import m_right_pocket from './right_pocket'

export default ember.Mixin.create m_initialize,
  m_config,
  m_addons,
  m_dock,
  m_top_pocket,
  m_right_pocket,

  reset_all: ->
    @reset_addons()
    @reset_dock()

  toString: -> 'AddonsService'

