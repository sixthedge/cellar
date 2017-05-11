import ember from 'ember'

export default ember.Mixin.create

  # From ember-data source for 'find':
  #   The default `model` hook in Ember.Route calls `find(modelName, id)`,
  #   that's why we have to keep this method around even though `findRecord` is
  #   the public way to get a record by modelName and id.
  # find: (model_name, id, options={}) -> find_record(model_name, id, options)

  find_record: (model_name, id, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @store.findRecord(model_name, id, options).then (record) =>
        resolve(record)
      , (error) =>
        @warn("Error in 'find_record' when querying for [#{model_name}] id: [#{id}] with: ", options)
        reject(error)

  find_record_with_message: (model_name, id, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @find_record(model_name, id, options).then (record) =>
        options.model  = record
        options.action = 'find'
        resolve(record)
        @totem_messages.api_success(options)
      , (error) =>
        options.model  = model_name
        options.id     = id
        options.action = 'find'
        @totem_messages.api_failure(error, options)
        reject(error)

  find_all: (model_name, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      key = model_name
      if @can_get_from_cache(key, options)
        resolve @get_from_cache(model_name)
      else
        @store.findAll(model_name, options).then (records) =>
          @set_cache(key, records)
          resolve(records)
        , (error) =>
          @warn("Error in 'find_all' when querying for [#{model_name}] with: ", options)
          reject(error)

  find_all_with_message: (model_name, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @find_all(model_name, options).then (records) =>
        options.model  = records
        options.action = 'find all'
        resolve(records)
        @totem_messages.api_success(options)
      , (error) =>
        options.model  = model_name
        options.action = 'find all'
        @totem_messages.api_failure(error, options)
        reject(error)
