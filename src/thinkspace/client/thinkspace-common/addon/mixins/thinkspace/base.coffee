import ember from 'ember'
# Mixins to build service.
import m_current_models   from './current_models'
import m_initialize       from './initialize'
import m_layout           from './layout'
import m_phase_settings   from './phase_settings'
import m_transition       from './transition'
import m_wizard           from './wizard'

export default ember.Mixin.create m_initialize,
  m_current_models,
  m_layout,
  m_phase_settings,
  m_transition,
  m_wizard
