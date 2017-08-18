import ember          from 'ember'
import ns             from 'totem/ns'
import totem_messages from 'totem-messages/messages'
import util           from 'totem/util'

export default ember.Service.extend

  query_params: {}

  set_query_param_for_route: (route_name, key, value) ->
    qp = @get('query_params')
    qp[route_name] = {} unless ember.isPresent(qp[route_name])
    qp[route_name][key] = value
