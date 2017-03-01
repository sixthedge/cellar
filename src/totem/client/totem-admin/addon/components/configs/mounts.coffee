import ember from 'ember'
import base  from 'totem-base/components/base'
import m_sort_by from 'totem-application/mixins/table_sort_by'

export default base.extend m_sort_by,
  tagName: ''

  admin: ember.inject.service()

  sorted_mounts: ember.computed.sort 'mounts', 'sort_by'

  sort: ember.computed ->
    sort_configs =
      engine: {id: 'engine', sort: 'sort_engine', text: 'Engine'}
      as:     {id: 'as', sort: 'sort_as', text: 'As'}
      under:  {id: 'under', sort: 'sort_under', text: 'Under'}
      path:   {id: 'path', sort: 'sort_path', text: 'Path'}
      route:  {id: 'route', sort: 'sort_route', text: 'Route'}

  init: ->
    @_super(arguments...)
    @am     = @get('admin')
    @mounts = @am.get_config_router_mounts()
    @set_default_sort_by ['engine', 'as']

  didInsertElement: -> @am.set_header_link_active('configs')
