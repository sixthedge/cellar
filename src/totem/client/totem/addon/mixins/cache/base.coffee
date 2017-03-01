import ember from 'ember'
# Mixins to build service.
import m_finders      from './finders'
import m_helpers      from './helpers'
import m_initialize   from './initialize'
import m_paginate     from './paginate'
import m_query        from './query'
import m_store        from './store'
import m_store_filter from './store_filter'
import m_view         from './view'

export default ember.Mixin.create m_initialize,
  m_finders,
  m_store,
  m_store_filter,
  m_paginate,
  m_query,
  m_view,
  m_helpers
