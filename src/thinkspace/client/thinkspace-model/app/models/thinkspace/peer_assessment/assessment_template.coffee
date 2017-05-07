import ember from 'ember'
import ta    from 'totem/ds/associations'
import base  from '../common/componentable'

export default base.extend ta.add(
    ta.polymorphic 'ownerable'
  ),

  title:          ta.attr('string')
  description:    ta.attr('string')
  state:          ta.attr('string')
  ownerable_id:   ta.attr('number')
  ownerable_type: ta.attr('string')
  value:          ta.attr()

  is_balance:    ember.computed.equal 'value.options.type', 'balance'
  is_categories: ember.computed.equal 'value.options.type', 'categories'

  is_system: ember.computed.equal 'state', 'system'
  is_user:   ember.computed.equal 'state', 'user'
