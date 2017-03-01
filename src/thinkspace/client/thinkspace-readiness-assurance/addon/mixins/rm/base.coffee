import ember from 'ember'
# Mixins to build response manager.
import m_chat       from './chat'
import m_helpers    from './helpers'
import m_initialize from './initialize'
import m_response   from './response'
import m_rooms      from './rooms'
import m_events     from './events'
import m_status     from './status'

export default ember.Mixin.create m_initialize,
    m_response,
    m_status,
    m_chat,
    m_rooms,
    m_events,
    m_helpers
