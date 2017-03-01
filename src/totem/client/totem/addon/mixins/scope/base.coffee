import ember from 'ember'
# Mixins to build service.
import m_ajax                 from './ajax'
import m_association_filters  from './association_filters'
import m_authable             from './authable'
import m_current_user         from './current_user'
import m_initialize           from './initialize'
import m_ownerable            from './ownerable'
import m_paths                from './paths'
import m_record_helpers       from './record_helpers'
import m_view_query           from './view_query'
import m_view_query_ids       from './view_query_ids'
import m_viewonly             from './viewonly'

export default ember.Mixin.create m_initialize,
  m_ajax,
  m_association_filters,
  m_authable,
  m_current_user,
  m_ownerable,
  m_paths,
  m_record_helpers,
  m_view_query,
  m_view_query_ids,
  m_viewonly,
