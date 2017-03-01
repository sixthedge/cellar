import ember from 'ember'
# Mixins to build service.
import m_configs    from './configs'
import m_helpers    from './helpers'
import m_initialize from './initialize'
import m_locales    from './locales'
import m_rooms      from './rooms'
import m_timers     from './timers'
import m_tracker    from './tracker'

export default ember.Mixin.create m_initialize,
  m_configs,
  m_locales,
  m_timers,
  m_tracker,
  m_rooms,
  m_helpers
