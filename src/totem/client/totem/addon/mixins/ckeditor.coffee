import ember from 'ember'
import util  from 'totem/util'
import config from 'totem-config/config'

export default ember.Mixin.create

  ckeditor_tag: null

  ckeditor_load: (asset_path='') ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve()  if typeof(window.CKEDITOR) == 'object'
      asset_path = config.asset_path
      asset_path += '/' unless util.ends_with(asset_path, '/')
      asset_path += 'ckeditor/'
      window.CKEDITOR_BASEPATH = asset_path  # must be set before loading CKEDITOR
      @totem_messages.show_loading_outlet()
      options = 
        dataType: 'script'
        cache:    true
        url:      asset_path + 'ckeditor.js'
      $.ajax(options).done =>
        options.url = asset_path + 'adapters/jquery.js'
        $.ajax(options).done =>
          @totem_messages.hide_loading_outlet()
          resolve()
        .fail =>
          reject('ckeditor jquery adapter load failed.')
      .fail =>
        reject('ckeditor load failed.')

  ckeditor_value: ($tag) ->
    $tag ?= @get('ckeditor_tag')
    return null unless $tag and $tag.length == 1
    $tag.ckeditor and $tag.ckeditor().val()

  ckeditor_destroy: ($tag) ->
    $tag ?= @get('ckeditor_tag')
    @set 'ckeditor_tag', null
    return null unless $tag and $tag.length == 1
    $tag.ckeditorGet and $tag.ckeditorGet().destroy()

  # This will live update the 'value' property
  # (e.g. need to model.rollback() to cancel changes bound to a model's attribute).
  ckeditor_view: ember.Object.extend
    tagName:      'textarea'
    ckeditor_tag: null

    didInsertElement: ->
      $tag = $(@element)
      @set 'ckeditor_tag', $tag
      value = @get('value') or ''
      $tag.html(value)
      @get('controller').ckeditor_load().then =>
        options =
          height: @get('height') or 100
        $tag.ckeditor (=> return), options
        $tag.editor.on 'change', (e) =>
          @set 'value', e.editor.getData()

    willDestroyElement: ->
      @get('controller').ckeditor_destroy(@get 'ckeditor_tag')
