import ember           from 'ember'
import totem_changeset from 'totem/changeset'
import base            from 'thinkspace-base/components/base'
import authenticate    from 'thinkspace-ltiv1/mixins/authenticate'

export default base.extend authenticate,

  query_param_keys: [
    'email',
    'user_id',
    'auth_token',
    'context_type',
    'context_id'
  ]

  init_base: ->
    @init_query_params()
    @authenticate()

  init_query_param: (param) ->
    value = @get_query_param(param)
    @get('lti_session').set_query_param_for_route('sign_in', param, value)
    @set param, value

  get_route: -> @get('container').lookup('route:sign_in')
