import ember  from 'ember'
# Mixins:
import m_auth       from './auth'
import m_cu         from './current_user'
import m_events     from './events'
import m_helpers    from './helpers'
import m_initialize from './initialize'
import m_non_auth   from './non_auth'
import m_rooms      from './rooms'
import m_timer      from './timer'
import m_tracker    from './tracker'
import m_trackersio from './tracker_sio'

export default ember.Mixin.create m_initialize,
  m_auth,
  m_non_auth,
  m_events,
  m_rooms,
  m_cu,
  m_helpers,
  m_timer,
  m_tracker,
  m_trackersio
