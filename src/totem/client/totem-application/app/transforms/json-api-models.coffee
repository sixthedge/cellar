import ember from 'ember'
import totem_scope from 'totem/scope'
import ds from 'ember-data'

export default ds.Transform.extend

  deserialize: (models) ->
    return null unless ember.isPresent(models)
    models  = ember.makeArray(models)
    store   = totem_scope.get_store()
    records = []
    models.forEach (hash) =>
      type          = hash.type
      id            = hash.id
      attributes    = hash.attributes or {}
      attrubutes.id = id unless ember.isPresent(attributes.id)
      if type and id
        record = store.push type, store.normalize(type, attributes)
        records.push(record)
    records

  serialize: (models) -> 
    models  = ember.makeArray(models)
    payload = []
    models.forEach (model) =>
      record = 
        type:       totem_scope.standard_record_path(model).pluralize()
        id:         model.get('id')
        attributes: model.serialize()
      payload.pushObject(record)
    payload
