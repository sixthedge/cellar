import ember from 'ember'
import base  from 'totem-base/components/base'

export default base.extend
  tagName:  ''
  sort_by:  'sort_by'
  clear_by: 'clear_by'

  is_asc:  ember.computed.equal 'sort.order', 'asc'
  is_desc: ember.computed.equal 'sort.order', 'desc'

  has_sort_order: ember.computed.or 'is_asc', 'is_desc'

  actions:
    sort:  -> @sendAction 'sort_by',  @sort
    clear: -> @sendAction 'clear_by', @sort
