import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  classNames: ['thinkspace-resource_file']

  ttz: ember.inject.service()

  selection: null
  prompt:    'No tag'

  file_updated_at: ember.computed 'model.file_updated_at', -> @get('ttz').format(@get('model.file_updated_at'), format: 'MMM Do, h:mm a')

  didInsertElement: -> @set 'selection', @get('model.tag')

  change: -> @save_tag()

  actions:
    destroy: ->
      file = @get 'model'
      file.deleteRecord()
      file.save().then =>
        @totem_messages.api_success source: @, model: file, action: 'delete', i18n_path: ns.to_o('file', 'destroy')
      , (error) =>
        @totem_messages.api_failure error, source: @, model: file, action: 'delete'

  save_tag: ->
    file    = @get 'model'
    new_tag = @get 'selection'
    tag_ids = (new_tag and new_tag.get 'id') or []
    file.set 'new_tags', ember.makeArray(tag_ids)
    file.save().then (file) =>
      @totem_messages.api_success source: @, model: file, i18n_path: ns.to_o('tag', 'save')
    , (error) =>
      @totem_messages.api_failure error, source: @, model: file
