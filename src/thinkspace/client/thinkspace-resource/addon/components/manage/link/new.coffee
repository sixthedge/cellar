import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'
import totem_changeset from 'totem/changeset'

export default base.extend

  init_base: ->
    model     = @tc.create_record ns.to_p('tag')
    vpresence = totem_changeset.vpresence(presence: true)
    @set 'changeset', totem_changeset.create model,
      title:    [vpresence]
      url:      [vpresence, totem_changeset.vurl()]
      new_tags: [vpresence]

    # @set 'model.selected_tag', @get('model.tag')
    # changeset = @get('changeset')
    # changeset.show_errors_on()
    # changeset.validate()
    # changeset.first_error_on()



  actions:
    cancel: -> @sendAction 'cancel'

    save: ->
      changeset = @get('changeset')
      console.warn 'save link model', changeset
      changeset.validate().then =>
        unless changeset.get('is_valid')
          changeset.show_errors_on()
          return
        # @get('tvo.status').update()
        # @changeset.set_ownerable()
        # @changeset.save().then =>
        #   @totem_messages.api_success source: @, model: @changeset.get_model(), action: 'save', i18n_path: ns.to_o('response', 'save')
        #   resolve()
        # , (error) =>
        #   @changeset.add_model_errors()
        #   # @totem_messages.api_failure error, source: @, model: @changeset.get_model()
        #   reject(error)


      # resourceable = @get 'resourceable'
      # title        = @get 'title'
      # url          = @get 'url'
      # link         = @tc.create_record ns.to_p('link'),
      #   title:             title
      #   url:               url
      #   resourceable_type: @totem_scope.record_type_key(resourceable)
      #   resourceable_id:   resourceable.get('id')
      # link.set_new_tags @get 'selection'
      # link.save().then (link) =>
      #   @totem_messages.api_success source: @, model: link, i18n_path: ns.to_o('link', 'save')
      #   @send 'cancel'
      # , (error) =>
      #   @totem_messages.api_failure error, source: @, model: link
