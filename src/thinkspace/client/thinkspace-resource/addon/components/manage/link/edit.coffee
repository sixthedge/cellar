import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'
import totem_changeset from 'totem/changeset'

export default base.extend

  init_base: ->
    model     = @get('model')
    vpresence = totem_changeset.vpresence(presence: true)
    @set 'changeset', totem_changeset.create model,
      title:    [vpresence]
      url:      [vpresence, totem_changeset.vurl()]
      new_tags: [vpresence]
    # model.get('tags').then (tags) =>
    #   model_tags = tags.map (tag) -> {id: tag.get('id'), title: tag.get('title')}
    #   console.warn model_tags
    #   @set 'model.new_tags', tags

  actions:
    cancel: -> @sendAction 'cancel'

    save:   ->
      link = @get 'model'
      # TODO: save the changeset
      # link.set 'title', @get('title')
      # link.set 'url',   @get('url')
      # link.set_new_tags @get 'selection'
      # link.save().then =>
      #   @totem_messages.api_success source: @, model: link, action: 'save', i18n_path: ns.to_o('link', 'save')
      #   @send 'cancel'
      # , (error) =>
      #   @totem_messages.api_failure error, source: @, model: link, action: 'save'
