import ember from 'ember'

export default ember.Mixin.create

  toString: -> 'TotemScope'

  instance: null

  get_instance:            -> @get 'instance'
  set_instance: (instance) -> @set 'instance', instance
  instance_lookup: (key)   -> @get_instance().lookup(key)

  # keeping until all refs changed to instance from container
  get_container:           -> @get_instance()
  container_lookup: (key)  -> @instance_lookup(key)

  # References the application's data store.
  data_store: null
  get_store: ->
    store = @get('data_store')
    return store if store
    store = @container_lookup('service:store')
    @set 'data_store', store
    store
