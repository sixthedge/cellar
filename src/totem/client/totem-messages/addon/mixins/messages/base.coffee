# Mixins to build messages service.
import ember     from 'ember'
import m_add     from './add'
import m_format  from './format'
import m_filter  from './filter'
import m_helpers from './helpers'
import m_init    from './initialize'
import m_item    from './item'
import m_load    from './load'

export default ember.Mixin.create(
  m_init,
  m_add,
  m_filter,
  m_item,
  m_format,
  m_load,
  m_helpers,
)
