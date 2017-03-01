import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.polymorphic 'resourceable'
    ta.has_many    'tags', reads: {}
  ),

  url:               ta.attr('string')
  title:             ta.attr('string')
  content_type:      ta.attr('string')
  size:              ta.attr('number')
  file_updated_at:   ta.attr('date')
  resourceable_type: ta.attr('string')
  resourceable_id:   ta.attr('string')
  new_tags:          ta.attr()

  tag: ember.computed.reads ta.to_prop('tags', 'firstObject')

  extension: ember.computed 'title', ->
    title = @get('title')
    '.' + title.split('.').pop()

  without_extension: ember.computed 'title', ->
    title = @get('title')
    parts = title.split('.')
    parts.pop()
    parts.join('.')

  human_size: ember.computed 'size', ->
    bytes     = @get('size')
    kilobytes = bytes / 1024
    megabytes = kilobytes / 1024
    gigabytes = megabytes / 1024
    return gigabytes.toFixed(1) + ' GB' if gigabytes >= 1
    return megabytes.toFixed(1) + ' MB' if megabytes >= 1
    return kilobytes.toFixed(1) + ' KB' if kilobytes >= 1
    return bytes.toFixed(1) + ' B'
