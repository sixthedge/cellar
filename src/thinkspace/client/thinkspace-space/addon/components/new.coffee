import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'
import totem_changeset from 'totem/changeset'

export default base.extend

  init_base: ->
    @create_changeset()

  create_changeset: ->
    model = @get('model')
    vlength = totem_changeset.vlength(min: 4)

    changeset = totem_changeset.create(model,
      title: [vlength]
    )

    changeset.show_errors_on()
    @set('changeset', changeset)

  actions:

    submit: ->
      @get('changeset').save().then =>
        @get('model').save().then (saved_model) =>
          @get_app_route().transitionTo 'spaces.index'