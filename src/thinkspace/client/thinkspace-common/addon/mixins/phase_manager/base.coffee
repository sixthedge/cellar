import ember from 'ember'
# Mixins to build service.
import m_addons        from './addons'
import m_debug         from './debug'
import m_generate_view from './generate_view'
import m_initialize    from './initialize'
import m_ownerable     from './ownerable'
import m_phase_states  from './phase_states'
import m_view_ability  from './view_ability'

export default ember.Mixin.create m_initialize,
  m_phase_states,
  m_view_ability,
  m_generate_view,
  m_ownerable,
  m_addons,
  m_debug
