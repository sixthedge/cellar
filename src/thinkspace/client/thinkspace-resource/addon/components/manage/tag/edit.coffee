import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend

  t_manage_tag_form: ns.to_t 'resource', 'manage', 'tag', 'form'

  placeholder: 'Tag title'
  title:       null

  actions:
    cancel: -> @sendAction 'cancel'

    save:   ->
      tag = @get 'model'
      tag.set 'title', @get('title')
      tag.save().then =>
        @totem_messages.api_success source: @, model: tag, action: 'save', i18n_path: ns.to_o('tag', 'save')
        @send 'cancel'
      , (error) =>
        @totem_messages.api_failure error, source: @, model: tag, action: 'save'

  didInsertElement: ->
    @set 'title',     @get('model.title')
