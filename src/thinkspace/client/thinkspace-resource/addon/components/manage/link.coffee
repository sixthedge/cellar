import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend
  classNames: ['thinkspace-resource_link']

  prompt:       'No tag'
  edit_visible: false

  actions:

    edit:   -> @set 'edit_visible', true
    cancel: -> @set 'edit_visible', false

    destroy: ->
      link = @get 'model'
      link.deleteRecord()
      link.save().then =>
        @totem_messages.api_success source: @, model: link, action: 'delete', i18n_path: ns.to_o('link', 'destroy')
      , (error) =>
        @totem_messages.api_failure error, source: @, model: link, action: 'delete'
