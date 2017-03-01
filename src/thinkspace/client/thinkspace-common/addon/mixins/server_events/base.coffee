import ember from 'ember'
# Mixins to build service.
import m_events     from './events'
import m_helpers    from './helpers'
import m_initialize from './initialize'
import m_messages   from './messages'
import m_rooms      from './rooms'
import m_routes     from './routes'
import m_timer      from './timer'
import m_tracker    from './tracker'
import m_trackersio from './tracker_sio'

export default ember.Mixin.create m_initialize,
  m_rooms,
  m_routes,
  m_events,
  m_messages,
  m_helpers,
  m_timer,
  m_tracker,
  m_trackersio

