import ember from 'ember'
# Mixins to build question manager.
import m_helpers    from './helpers'
import m_initialize from './initialize'
import m_rooms      from './rooms'
import m_status     from './status'
import m_values     from './values'

export default ember.Mixin.create m_initialize,
    m_values,
    m_rooms,
    m_status,
    m_helpers
