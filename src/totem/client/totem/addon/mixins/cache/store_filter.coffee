import ember from 'ember'

export default ember.Mixin.create

  filter: (model_name, fn) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @store.filter(model_name, fn).then (filtered_store_records) =>
        resolve(filtered_store_records)
      , (error) =>
        @warn("Error in 'store_filter'.")
        reject(error)

    # @store.filter(type, (record) =>
    #   filter_ids.includes record.get(id_prop)
    # ).then (filtered_store_records) =>
    #   resolve(filtered_store_records)
    # , (error) =>
    #   reject(error)
