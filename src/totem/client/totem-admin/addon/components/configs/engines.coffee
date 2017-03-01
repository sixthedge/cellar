import ember from 'ember'
import base  from 'totem-base/components/base'
import m_sort_by from 'totem-application/mixins/table_sort_by'

export default base.extend m_sort_by,
  tagName: ''

  admin: ember.inject.service()

  default_services: ember.computed -> @get('admin').get_default_services().join(', ')

  sorted_engines: ember.computed.sort 'engines', 'sort_by'

  sort: ember.computed ->
    sort_configs =
      engine:          {id: 'name', sort: 'sort_name', text: 'Engine'}
      external_routes: {id: 'external_routes', sort: 'sort_external_routes', text: 'External Routes'}
      services:        {id: 'services', sort: 'sort_services', text: 'Services'}
      add_engines:     {id: 'add_engines', sort: 'sort_add_engines', text: 'Add Engines'}

  init: ->
    @_super(arguments...)
    @am      = @get('admin')
    @engines = @am.get_config_engines()
    @set_default_sort_by ['name']

  didInsertElement: -> @am.set_header_link_active('configs')
