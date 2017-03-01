import ember from 'ember'
import ta    from 'totem/ds/associations'
import base  from '../common/componentable'

export default base.extend ta.add(
    ta.polymorphic 'ownerable'
    ta.belongs_to  'bucket', reads: {}
  ),

  user_id:               ta.attr('number')
  url:                   ta.attr('string')
  title:                 ta.attr('string')
  content_type:          ta.attr('string')
  size:                  ta.attr('number')
  attachment_updated_at: ta.attr('date')
  updateable:            ta.attr('boolean')
  ownerable_id:          ta.attr('number')  # used in filter
  ownerable_type:        ta.attr('string')  # used in filter

  authable: ember.computed ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      @get(ta.to_p 'bucket').then (bucket) =>
        bucket.get('authable').then (authable) =>
          resolve(authable)
    ta.PromiseObject.create promise: promise

  extension: ember.computed 'title', ->  '.' + @get('title').split('.').pop()
  is_pdf:    ember.computed.equal 'extension', '.pdf'

  without_extension: ember.computed 'title', ->
    title = @get 'title'
    parts = title.split('.')
    parts.pop()
    parts.join('.')

  friendly_size: ember.computed 'size', ->
    bytes     = @get 'size'
    kilobytes = bytes / 1024
    megabytes = kilobytes / 1024
    gigabytes = megabytes / 1024
    return gigabytes.toFixed(1) + ' GB' if gigabytes >= 1
    return megabytes.toFixed(1) + ' MB' if megabytes >= 1
    return kilobytes.toFixed(1) + ' KB' if kilobytes >= 1
    return bytes.toFixed(1) + ' B'

  container_id: ember.computed 'id', -> "ts-artifact_file-#{@get('id')}"

  # didCreate: -> @didLoad()
  #
  # didLoad: ->
  #   @get(ta.to_p 'bucket').then (bucket) =>
  #     bucket.get(ta.to_p 'artifact:files').then (files) =>
  #       files.pushObject(@) unless files.contains(@)
