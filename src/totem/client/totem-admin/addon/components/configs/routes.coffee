import ember from 'ember'
import base  from 'totem-base/components/base'
import m_sort_by from 'totem-application/mixins/table_sort_by'

export default base.extend m_sort_by,
  tagName: ''

  admin: ember.inject.service()

  sorted_routes: ember.computed.sort 'routes', 'sort_by'

  sort: ember.computed ->
    sort_configs =
      name: {id: 'name', sort: 'sort_engine', text: 'Name'}
      path:   {id: 'path', sort: 'sort_path', text: 'Path'}

  init: ->
    @_super(arguments...)
    @am     = @get('admin')
    @routes = @am.get_config_routes()
    @set_default_sort_by ['name']

  didInsertElement: -> @am.set_header_link_active('configs')
