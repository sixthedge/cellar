import ember from 'ember'

export default ember.Mixin.create

  # Adds authable and ownerable to query params on ajax requests.
  # The adapter/serializer override the base functions to call the related
  # function below.  A query object is always passed as an argument.

  # ### Adapter
  delete_record: (type, record, query) -> @add_auth_to_query(type, query)  # deleteRecord.
  find:          (type, id, query)     -> @add_auth_to_query(type, query)  # find with id.
  find_all:      (type, query)         -> @add_auth_to_query(type, query)  # findAll (e.g. no id).
  find_many:     (type, query)         -> @add_auth_to_query(type, query)  # findMany e.g. 'select' queries.
  find_query:    (type, query)         -> @add_auth_to_query(type, query)  # findQuery e.g. find with object instead of id.

  # ### Serializer
  # Serializer serializeIntoHash is called when serializing a record.
  # This function is called before the record is serialized so the record's ownerable attributes could be updated.
  serialize_into_hash: (hash, type, record, options) ->  @add_auth_to_query(type, hash)

  # ### Rest Helpers

  add_auth_to_query: (object, query={}) ->
    return unless object and query
    object = object.constructor  unless ember.get(object, 'isClass')
    @add_ownerable_to_query(query)  if ember.get(object, 'include_ownerable_in_query') or query.ownerable
    @add_authable_to_query(query)   if ember.get(object, 'include_authable_in_query')  or query.authable
    @add_sub_action_to_query(query)
    delete(query.ownerable)
    delete(query.authable)
    delete(query.sub_action)

  add_ownerable_to_query: (query, ownerable=null) ->
    query.auth ?= {}
    if ownerable or (ownerable = query.ownerable)
      ownerable_type = @get_record_path(ownerable)
      ownerable_id   = ownerable.get('id')
    else
      @ownerable_to_current_user()  unless @has_ownerable()
      ownerable_type = @get_ownerable_type()
      ownerable_id   = @get_ownerable_id()
    query.auth.ownerable_type = ownerable_type
    query.auth.ownerable_id   = ownerable_id

  add_authable_to_query: (query, authable=null) ->
    query.auth ?= {}
    if authable or (authable = query.authable)
      authable_type = @get_record_path(authable)
      authable_id   = authable.get('id')
    else
      authable_type = @get_authable_type()
      authable_id   = @get_authable_id()
    query.auth.authable_type = authable_type
    query.auth.authable_id   = authable_id

  add_sub_action_to_query: (query, sub_action=null) ->
    return if query.auth and query.auth.sub_action
    if sub_action or (sub_action = query.sub_action)
      query.auth ?= {}
      query.auth.sub_action = sub_action
      return

  # Add the auth values to an ajax query (e.g. not a @store query).
  # Adds the sub 'data' object if does not exist.
  add_auth_to_ajax_query: (query={}) ->
    query.data ?= {}
    query.data.authable   = query.authable   unless query.data.authable
    query.data.ownerable  = query.ownerable  unless query.data.ownerable
    query.data.sub_action = query.sub_action unless query.data.sub_action
    delete(query.authable)
    delete(query.ownerable)
    delete(query.sub_action)
    @add_authable_to_query(query.data)
    @add_ownerable_to_query(query.data)
    @add_sub_action_to_query(query.data)
    delete(query.data.authable)
    delete(query.data.ownerable)
    delete(query.data.sub_action)
    query
