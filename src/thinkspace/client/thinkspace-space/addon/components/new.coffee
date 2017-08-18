import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'
import totem_changeset from 'totem/changeset'

export default base.extend

  lti_session: ember.inject.service()

  get_route: -> @get('container').lookup('route:new')

  init_base: ->
    @set 'lti_setup', @get_query_param('lti_setup')
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
          @totem_messages.api_success source: @, model: saved_model, action: 'save', i18n_path: ns.to_o('space', 'save')
          if @get('lti_setup')
            lti_query_params = @get('lti_session.query_params.setup')
            @get_route().transitionToExternal 'lti.setup', { queryParams: lti_query_params }
          else
            @get_app_route().transitionTo 'spaces.index'