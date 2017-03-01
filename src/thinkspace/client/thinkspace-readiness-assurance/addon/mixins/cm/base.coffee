import ember from 'ember'
# Mixins to build question manager.
import m_helpers    from './helpers'
import m_initialize from './initialize'
import m_values     from './values'

export default ember.Mixin.create m_initialize,
    m_helpers,
    m_values
