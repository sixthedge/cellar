import ember from 'ember'
# Mixins.
import m_array    from './array'
import m_console  from './console'
import m_date     from './date_time'
import m_hash     from './hash'
import m_is       from './is'
import m_module   from './module'
import m_object   from './object'
import m_number   from './number'
import m_string   from './string'

export default ember.Mixin.create m_console,
  m_array,
  m_hash,
  m_is,
  m_module,
  m_object,
  m_number,
  m_string,
  m_date,

  toString: -> 'TotemUtilEmber'
