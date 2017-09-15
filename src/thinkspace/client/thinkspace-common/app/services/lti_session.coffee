import ember          from 'ember'
import ns             from 'totem/ns'
import totem_messages from 'totem-messages/messages'
import util           from 'totem/util'

export default ember.Service.extend

  query_params: {}
  will_redirect: false

  get_redirect_query_params: -> 
    route = @get('redirect_route')
    @get('query_params')[route]

  set_query_param_for_route: (route_name, key, value) ->
    qp = @get('query_params')
    qp[route_name] = {} unless ember.isPresent(qp[route_name])
    qp[route_name][key] = value

  set_redirect: (route) ->
    @set 'will_redirect', true
    @set 'redirect_route', route
    @set 'redirect_external_route', "lti.#{route}"

  reset_redirect: ->
    @set 'will_redirect', false
    @set 'redirect_route', null
    @set 'redirect_external_route', null


