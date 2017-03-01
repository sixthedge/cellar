import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend

  t_manage_tag_form: ns.to_t 'resource', 'manage', 'tag', 'form'

  placeholder: 'New tag title'
  title:       null

  actions:
    cancel: -> @sendAction 'cancel'

    save:   ->
      taggable = @get 'taggable'
      title    = @get 'title'
      tag      = @tc.create_record ns.to_p('tag'),
        title:         title
        taggable_type: @totem_scope.record_type_key(taggable)
        taggable_id:   taggable.get('id')
      tag.save().then (link) =>
        @totem_messages.api_success source: @, model: tag, i18n_path: ns.to_o('tag', 'save')
        @send 'cancel'
      , (error) =>
        @totem_messages.api_failure error, source: @, model: tag
