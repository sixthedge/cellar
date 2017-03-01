import ember from 'ember'

export default ember.Mixin.create

  # The server's controller 'action' to be called to return ownerable based data (e.g. for a user or team).
  ownerable_data_action: (record) -> (@is_function(record.ownerable_data_action) and record.ownerable_data_action()) or 'view'

  # View query options: 
  #   verb:       default 'post'
  #   action:     default 'view'
  #   id:         default record.id
  #   sub_action: default null
  #   view_ids:   default ownerable.id
  #   view_type:  default ownerable.type
  #   authable:   default totem_scope.authable
  #   ownerable:  default totem_scope.ownerable

  get_view_query: (record, options={}) ->
    query           = {}
    query.verb      = options.verb   or 'post'
    query.action    = options.action or @ownerable_data_action(record)
    query.model     = record
    query.id        = options.id or record.get('id')
    data            = query.data or {}
    data.sub_action = options.sub_action or null
    data.authable   = options.authable   or null
    data.ownerable  = options.ownerable  or null
    auth            = data.auth  or {}
    auth.view_ids   = @get_view_query_view_ids(options)
    auth.view_type  = @get_view_query_view_type(options)
    query.data      = data
    query.data.auth = auth
    query

  get_view_query_view_ids: (options={}) ->
    switch
      when ember.isPresent(options.view_ids)  then ids = options.view_ids
      when ember.isPresent(options.ownerable) then ids = options.ownerable.get('id')
      else ids = @get_ownerable_id()
    ember.makeArray(ids)

  get_view_query_view_type: (options={}) ->
    switch
      when ember.isPresent(options.view_type)  then type = options.view_type
      when ember.isPresent(options.ownerable)  then type = @record_model_name(options.ownerable)
      else type = @get_ownerable_type()
    type

  # Return a query to load a record's unviewed ids.
  # Returns null if all ids are loaded.
  get_unviewed_query: (record, options={}) ->
    unviewed_ids = @get_unviewed_record_path_ids(record, options)
    @set_viewed_record_path_ids(record, options)  unless options.set_viewed == false
    return null if @is_blank(unviewed_ids)
    options.view_ids = unviewed_ids
    @get_view_query(record, options)
