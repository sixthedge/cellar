import ember from 'ember'

export default ember.Mixin.create

  query: (model_name, query) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @store.query(model_name, query).then (records) =>
        resolve(records)
      , (error) =>
        @warn("Error in 'query' when querying for [#{model_name}] with: ", query)
        reject(error)

  query_record: (model_name, query, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      key = @get_query_cache_key(model_name, query, options)
      if @can_get_from_cache(key, options)
        resolve @get_from_cache(key)
      else
        @store.queryRecord(model_name, query).then (records) =>
          @set_cache(key, records)
          resolve(records)
        , (error) =>
          @warn("Error in 'query_record' when querying for [#{model_name}] with: ", query, options)
          reject(error)

  # Raw JSON - not ember-data object format.
  query_data: (model_name, query, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @query_ajax_object(model_name, query, options).then (payload) =>
        resolve(payload)
      , (error) => 
        @warn(reject, "Error in 'query_data' when querying for [#{model_name}] with: ", query, options)
        reject(error)

  # Ember-data object format, hitting an action on a model's base API endpoint.
  query_action: (model_name, query, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @query_ajax_object(model_name, query, options).then (payload) =>
        model   = @get_model_name(model_name, options)
        records = @push_payload_and_return_records_for_type(payload, model, options)
        resolve(records)
      , (error) => @warn("Error in 'query_action' when querying for [#{model_name}] with: ", query, options)
    , (error) => @warn("2: Error in 'query_record' when querying for [#{model_name}] with: ", query, options)

  # Essentially `query_action`, but returns a paginated array and expects page params.
  query_paginated: (model_name, query, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      page = query.page
      unless ember.isPresent(page) and ember.isPresent(page.number) and ember.isPresent(page.size)
        @warn("Error in `query_paginated` - cannot query without a page.number and a page.size: ", page.number, page.size)
        return resolve([])
      @query_ajax_object(model_name, query, options).then (payload) =>
        model = @get_model_name(model_name, options)
        array = @get_paginated_array(model, payload)
        resolve(array)
      , (error) => @warn("Error in `query_paginated when querying for [#{model_name}] with: ", query, options)
    , (error) => @warn("2: Error in `query_paginated when querying for [#{model_name}] with: ", query, options)

  # ###
  # ### Helpers
  # ###

  get_model_name: (model_name, options={}) -> (options.model or model_name or '').dasherize().split('-').join('_')

  query_ajax_object: (model_name, query, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      # Extract relevant keys, then remove from payload so they are not sent.
      action              = options.action or ''
      verb                = options.verb   or 'GET'
      url                 = options.url    or null
      id                  = query.id       or null
      if ember.isPresent(url)
        ao_options = {url: url, data: query, verb: verb}
      else
        ao_options = {model: model_name, data: query, action: action, verb: verb, id: id}
      @ajax.object(ao_options).then (payload) =>
        resolve(payload)
      , (error) => 
        @warn("Error in 'query_ajax_object' when querying with: ", query, options)
        reject(error)

  push_payload_and_return_data_record: (payload) ->
    return null if ember.isBlank(payload)
    @push_payload(payload)
    data = payload.data or {}
    id   = data.id
    type = data.type
    if ember.isBlank(id)
      @warn "Payload data id is blank.", data
      return null
    if ember.isBlank(type)
      @warn "Payload data type is blank.", data
      return null
    @peek_record(type, id)

  push_payload_and_return_records_for_type: (payload, type, options={}) ->
    @push_payload(payload)
    payload_by_type = @get_payload_by_record_type(payload)
    ids             = @get_payload_record_ids(payload_by_type[type])
    records         = @get_data_records_for_ids(type, ids)
    records         = records.get('firstObject') if options.single
    records

  get_payload_by_record_type: (payload) ->
    records = new Object
    @add_payload_to_records(payload.data, records)
    @add_payload_to_records(payload.included, records)
    records

  add_payload_to_records: (data, records={}) ->
    return unless ember.isPresent(data) and !ember.isEmpty(data)
    data = ember.makeArray(data)
    data.forEach (record) =>
      type          = (record.type or '').underscore() # push payload dasherizes the record types
      records[type] = new Array unless ember.isArray(records[type])
      records[type].pushObject(record)

  get_data_records_for_ids: (type, ids) ->
    return [] if ember.isBlank(ids) or ember.isBlank(type)
    store_records = @store.peekAll(type)
    records       = []
    # Doing this rather than a store filter to retain order for server-sdie sorts.
    ids.forEach (id) =>
      record = store_records.findBy('id', id)
      records.pushObject(record)
    records

  get_payload_record_ids: (records) ->
    return [] if ember.isBlank(records)
    ember.makeArray(records).map (record) -> "#{record.id}" # make id a string

  get_payload_record_type: (records) ->
    return null if ember.isBlank(records)
    records.get('firstObject').type
