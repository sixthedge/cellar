import ember from 'ember'

export default ember.Mixin.create

  create_record: (model_name, props) -> @store.createRecord(model_name, props)

  delete_record: (record) -> @store.deleteRecord(record)

  has_record_for_id: (model_name, id) -> @store.hasRecordForId(model_name, id)

  model_for: (model_name) -> @store.modelFor(model_name)

  normalize: (model_name, payload) -> @store.normalize(model_name, payload)

  peek_record: (model_name, id) -> @store.peekRecord(model_name, id)

  peek_all: (model_name) -> @store.peekAll(model_name)

  push: (data) -> @store.push(data) # push normalized JSON API data
  
  push_payload:  (model_name, payload) -> @store.pushPayload(model_name, payload)
  
  record_is_loaded: (model_name, id) -> @has_record_for_id(model_name, id) # alias for has_record_for_id

  unload_all:    (model_name) -> @store.unloadAll(model_name)
  
  unload_record: (record) -> @store.unloadRecord(record)

  push_many:     (args...) -> @warn('Store [push_many] not implemented.', args)
