import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ember.Mixin.create ta.add(
    ta.has_many 'files', reads: {sort: ['title:asc', 'file_updated_at:asc']}
    ta.has_many 'links', reads: {sort: 'title:asc'}
    ta.has_many 'tags',  reads: {sort: 'title:asc'}
  ),

  has_resources_mixin: true

  has_files:     ember.computed.notEmpty ta.to_p('files')
  has_links:     ember.computed.notEmpty ta.to_p('links')
  has_resources: ember.computed.or 'has_files', 'has_links'

  # resources_length: ember.computed ta.to_prop('files', '@each'), ta.to_prop('links', '@each'), -> @get('files.length') + @get('links.length')
  resources_length: ember.computed ta.to_prop('files', '[]'), ta.to_prop('links', '[]'), -> @get('files.length') + @get('links.length')

  # Helpers to aid in the rendering of tagless files.
  tagless_files:     ember.computed ta.to_prop('files', '@each.tag'), -> @get(ta.to_p 'files').reject (file) -> file.get(ta.to_prop 'tags', 'length') > 0
  tagless_links:     ember.computed ta.to_prop('links', '@each.tag'), -> @get(ta.to_p 'links').reject (link) -> link.get(ta.to_prop 'tags', 'length') > 0
  tagless_resources: ember.computed 'tagless_files', 'tagless_links', -> @get('tagless_files').concat(@get 'tagless_links')
