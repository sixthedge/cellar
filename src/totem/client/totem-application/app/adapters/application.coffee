import ember       from 'ember'
import ds          from 'ember-data'
import config      from 'totem-config/config'
import totem_scope from 'totem/scope'
import auth_mixin  from 'ember-simple-auth/mixins/data-adapter-mixin'

export default ds.JSONAPIAdapter.extend auth_mixin,

  namespace:  'api'
  host:       config.api_host
  authorizer: 'authorizer:totem'

  coalesceFindRequests: true

  headersForRequest: (params) ->
    headers = @_super(params)
    ember.merge headers, @get_auth_headers()
    headers

  get_auth_headers: ->
    headers = {}
    session = @get('session')
    data    = session.get('session.content.authenticated') or null
    if data
      headers.Authorization = 'Token ' + 'token' + '="' + data.token + '", ' + 'email' + '="' + data.email + '"'
    headers

  findMany: (store, type, ids, snapshots) ->
    # console.warn query
    query = {ids: ids}
    totem_scope.find_many(type, query)
    url = @buildURL(type.modelName, ids, snapshots, 'findMany') + '/select'
    @ajax url, 'GET', data: query

  findRecord: (store, type, id, snapshot) ->
    query = {}
    totem_scope.find(type, id, query)
    url = @buildURL(type.modelName, id, snapshot, 'findRecord')
    @ajax(url, 'GET', data: query)

  # Override pathForType to underscore the path (otherwise is dasherized).
  pathForType: (modelName) ->
    path = @_super(modelName)
    ember.String.underscore(path)

  # For request errors, set the status in the errors hash.
  handleResponse: (status, headers, payload, requestData) ->
    payload.errors.status = status if status >= 400 and payload.errors
    @_super(status, headers, payload, requestData)