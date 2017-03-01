import ember from 'ember'
# Mixins to build phase manager map.
import m_initialize    from './initialize'
import m_finders       from './finders'
import m_map           from './map'
import m_mock          from './mock'
import m_phase_states  from './phase_states'
import m_print         from './print'

export default ember.Object.extend m_initialize,
  m_map,
  m_phase_states,
  m_finders,
  m_mock,
  m_print
