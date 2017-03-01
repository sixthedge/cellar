import ember from 'ember'

export default ember.Mixin.create

  # View options 'default' to the current totem scope 'ownerable' and 'authable'.
  # See totem scope view query for option values and defaults.

  # success -> resolve()
  # failure -> reject(error)
  # options: {reload: true) #=> reload records regardless if already loaded
  # If the records are already loaded then resolve (unless options.reload == true) else
  # send an ajax request to get the payload, push the payload into the store and resolve.
  view_load: (model, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      if @is_reload(options)
        query = @totem_scope.get_view_query(model, options)
      else
        query = @totem_scope.get_unviewed_query(model, options)
        return resolve() if ember.isBlank(query) # if the query is null, the record's ownerable data have already been loaded
      @ajax.object(query).then (payload) =>
        @push_payload(payload)
        resolve()
      , (error) =>
        reject(error)

  # success -> resolve(payload)
  # failure -> reject(error)
  # Will always send ajax request.
  # Does NOT push the records into the store.
  view_payload: (model, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      query = @totem_scope.get_view_query(model, options)
      @ajax.object(query).then (payload) =>
        resolve(payload)
      , (error) =>
        reject(error)

  # success -> resolve(data-record)
  # failure -> reject(error)
  # Will always send ajax request.
  # Pushes the payload and returns the record in payload.data.
  view_data_record: (model, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @view_payload(model, options).then (payload) =>
        resolve @push_payload_and_return_data_record(payload)
      , (error) =>
        reject(error)
