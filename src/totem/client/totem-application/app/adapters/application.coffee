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

  # query: (store, type, query) ->
  #   console.warn query
  #   totem_scope.find_query(type, query)
  #   url = @buildURL(type.modelName, null, null, 'query', query)
  #   url += "/#{query.action}"  if query.action
  #   @ajax(url, 'GET', query)

  # Override pathForType to underscore the path (otherwise is dasherized).
  pathForType: (modelName) ->
    path = @_super(modelName)
    ember.String.underscore(path)

  # ajax: (url, type, hash={}) ->
  #   timeout      = config and config.ajax_timeout
  #   hash.timeout = timeout  if timeout
  #   # console.warn url, type, hash
  #   @_super(url, type, hash)

  # findRecord: (store, type, id, snapshot) ->
  #   query = {}
  #   totem_scope.find_record(type, id, query)
  #   url = @buildURL(type.modelName, id, snapshot, 'findRecord')
  #   @ajax(url, 'GET', data: query)

  # findMany: (store, type, ids, snapshots) ->
  #   query = {ids: ids}
  #   totem_scope.find_many(type, query)
  #   url = @buildURL(type.modelName, ids, snapshots, 'findMany') + '/select'
  #   @ajax url, 'GET', data: query

  # findAll: (store, type, sinceToken) ->
  #   query       = {}
  #   query.since = sinceToken  if sinceToken
  #   totem_scope.find_all(type, query)
  #   url = @buildURL(type.modelName, null, null, 'findAll')
  #   @ajax(url, 'GET', data: query)

  # # Return a single record from the query.
  # queryRecord: (store, type, query) ->
  #   totem_scope.query_record(type, query)
  #   url = @buildURL(type.modelName, null, null, 'queryRecord', query)
  #   @send_query(url, query)

  # Return an array of records from the query.
  # query: (store, type, query) ->
  #   totem_scope.query(type, query)
  #   url = @buildURL(type.modelName, null, null, 'query', query)
  #   @send_query(url, query)

  # send_query: (url, query) ->
  #   id     = query.id
  #   action = query.action
  #   verb   = query.verb or 'GET'
  #   url   += '/' + id     if id
  #   url   += '/' + action if action
  #   delete(query.id)      if query.id
  #   delete(query.action)  if query.action
  #   delete(query.verb)    if query.verb
  #   query = @sortQueryParams(query)  if @sortQueryParams
  #   @ajax(url, verb, data: query)
  #

  # # Delete record does not go through the rest_serializer's 'serializeIntoHash' function
  # # so the totem_scope information must be added in the rest_adapter.
  # # Calls to 'totem_scope' add the authable/ownerable model type and id when appropriate.
  # deleteRecord: (store, type, record) ->
  #   query = {}
  #   totem_scope.delete_record(type, record, query)
  #   id = record.get 'id'
  #   @ajax(@buildURL(type.typeKey, id), "DELETE", data: query);

  # # Override this so that the 422 error do not get gobbled.
  # ajaxError: (jqXHR, responseText, errorThrown) ->
  #   isObject = jqXHR != null and typeof jqXHR == 'object'
  #   if isObject
  #     jqXHR.then = null
  #     if !jqXHR.errorThrown
  #       if typeof errorThrown == 'string'
  #         jqXHR.errorThrown = new Error(errorThrown)
  #       else
  #         jqXHR.errorThrown = errorThrown
  #   jqXHR

  # ### OTHER REST ADAPTER FUNCTIONS ###

  #   Called by the store in order to fetch a JSON array for
  #   the unloaded records in a has-many relationship that were originally
  #   specified as a URL (inside of `links`).
  #   For example, if your original payload looks like this:
  #   {
  #     "post": {
  #       "id": 1,
  #       "title": "Rails is omakase",
  #       "links": { "comments": "/posts/1/comments" }
  #     }
  #   }
  #   This method will be called with the parent record and `/posts/1/comments`.
  #   The `findHasMany` method will make an Ajax (HTTP GET) request to the originally specified URL.
  #   @method findHasMany
  #   @param {DS.Store} store
  #   @param {DS.Snapshot} snapshot
  #   @param {String} url
  #   @return {Promise} promise
  # findHasMany: function(store, snapshot, url, relationship) {
  #   var id   = snapshot.id;
  #   var type = snapshot.modelName;
  #   url = this.urlPrefix(url, this.buildURL(type, id, null, 'findHasMany'));
  #   return this.ajax(url, 'GET');
  # },

  #   Called by the store in order to fetch a JSON array for
  #   the unloaded records in a belongs-to relationship that were originally
  #   specified as a URL (inside of `links`).
  #   For example, if your original payload looks like this:
  #   {
  #     "person": {
  #       "id": 1,
  #       "name": "Tom Dale",
  #       "links": { "group": "/people/1/group" }
  #     }
  #   }
  #   This method will be called with the parent record and `/people/1/group`.
  #   The `findBelongsTo` method will make an Ajax (HTTP GET) request to the originally specified URL.
  #   @method findBelongsTo
  #   @param {DS.Store} store
  #   @param {DS.Snapshot} snapshot
  #   @param {String} url
  #   @return {Promise} promise
  # findBelongsTo: function(store, snapshot, url, relationship) {
  #   var id   = snapshot.id;
  #   var type = snapshot.modelName;
  #   url = this.urlPrefix(url, this.buildURL(type, id, null, 'findBelongsTo'));
  #   return this.ajax(url, 'GET');
  # },


  # import ember  from 'ember'
  # import ds     from 'ember-data'
  # import config from 'totem-config/config'
  # import totem_scope    from 'totem/scope'
  # import totem_messages from 'totem-messages/messages'
  #
  # # export default ds.ActiveModelAdapter.extend
  # export default ds.JSONAPIAdapter.extend
  #   namespace: 'api'
  #   # host:      config.api_host
  #
  #   # coalesceFindRequests: true

    # ajax: (url, type, hash={}) ->
    #   timeout      = config and config.ajax_timeout
    #   hash.timeout = timeout  if timeout
    #   @_super(url, type, hash)
    #
    # # findQuery looks for the query object keys 'action', 'id', and 'verb'.
    # # They will be deleted from the query params base on:
    # #  * If query contains both 'action' and 'id' then format the url for a :member request.
    # #      e.g. base_url/id/action  #=> delete action and id from query
    # #  * If query has an 'action' but no 'id' then format the url for a :collection request.
    # #      e.g. base_url/action     #=> delete action from query
    # #  * If query does not have an action (e.g. null) then get a standard buildURL (e.g. the null is ignored).
    # #  * Always deletes the 'verb' key and either uses it in the buildURL or defaults to 'GET'.
    # # Note: Latest ember-data buildURL will convert '/' to '%2F' so need to add the action after the url is built.
    # findQuery: (store, type, query) ->
    #   totem_scope.find_query(type, query)  # add model type and id
    #   action = query.action
    #   id     = query.id
    #   verb   = query.verb or 'GET'
    #   url    = @buildURL(type.typeKey, id)
    #   url   += '/' + action if action
    #   delete(query.id)      if query.id
    #   delete(query.action)  if query.action
    #   delete(query.verb)    if query.verb
    #   @ajax(url, verb, { data: query })
    #
    # # Delete record does not go through the rest_serializer's 'serializeIntoHash' function
    # # so the totem_scope information must be added in the rest_adapter.
    # # Calls to 'totem_scope' add the authable/ownerable model type and id when appropriate.
    # deleteRecord: (store, type, record) ->
    #   query = {}
    #   totem_scope.delete_record(type, record, query)
    #   id = record.get 'id'
    #   @ajax(@buildURL(type.typeKey, id), "DELETE", data: query);
    #
    # find: (store, type, id) ->
    #   query = {}
    #   totem_scope.find(type, id, query)
    #   @ajax(@buildURL(type.typeKey, id), 'GET', data: query);
    #
    # findAll: (store, type, sinceToken) ->
    #   query = {}
    #   query.since = sinceToken  if sinceToken
    #   totem_scope.find_all(type, query)
    #   @ajax(@buildURL(type.typeKey), 'GET', { data: query });
    #
    # findMany: (store, type, ids) ->
    #   query = {ids: ids}
    #   totem_scope.find_many(type, query)
    #   @ajax(@buildURL(type.typeKey, 'select'), 'GET', data: query)
    #
    # # Override this so that the 422 error does not get gobbled.
    # ajaxError: (jqXHR, responseText, errorThrown) ->
    #   isObject = jqXHR != null and typeof jqXHR == 'object'
    #   if isObject
    #     jqXHR.then = null
    #     if !jqXHR.errorThrown
    #       if typeof errorThrown == 'string'
    #         jqXHR.errorThrown = new Error(errorThrown)
    #       else
    #         jqXHR.errorThrown = errorThrown
    #   jqXHR
