import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  classNames: ['thinkspace-resource_tag']

  c_manage_tag_edit: ns.to_p 'resource', 'manage', 'tag', 'edit'

  edit_visible: false

  actions:

    edit:   -> @set 'edit_visible', true
    cancel: -> @set 'edit_visible', false

    destroy: ->
      tag = @get 'model'
      tag.deleteRecord()
      tag.save().then =>
        @totem_messages.api_success source: @, model: tag, action: 'delete', i18n_path: ns.to_o('tag', 'destroy')
      , (error) =>
        @totem_messages.api_failure error, source: @, model: tag, action: 'delete'
