import ember from 'ember'

export default ember.Mixin.create

## ###
## Ember Model Helpers
## ###

  # sets a polymorphic relationship, id, and type
  set_polymorphic: (record, property, value, totem_scope=null) ->
    unless @all_present([record, property, value])
      console.warn "No record, property, or value provided to set_polymorphic, relationship not set.", @
      return
    totem_scope = totem_scope || @totem_scope
    record.set property, value
    record.set "#{property}_id", value.get('id')
    record.set "#{property}_type", totem_scope.get_record_path(value) if ember.isPresent totem_scope

  # save all records in an enumeration
  save_all: (records) ->
    new ember.RSVP.Promise (resolve, reject) =>
      promises = []
      records.forEach (record) =>
        promises.pushObject(@save_if_changed(record))
      ember.RSVP.Promise.all(promises).then (saved_records) =>
        resolve(saved_records)

  # saves the record if dirty, always returns a promise
  save_if_changed: (record) ->
    new ember.RSVP.Promise (resolve, reject) =>
      if record.get('isDirty')
        record.save().then (saved_record) =>
          resolve saved_record
      else
        resolve record

  # destroy all records in an enumeration
  destroy_all: (records) ->
    new ember.RSVP.Promise (resolve, reject) =>
      promises = []
      records.forEach (record) =>
        promises.pushObject(record.destroyRecord())
      ember.RSVP.Promise.all(promises).then (destroyed_records) =>
        resolve(destroyed_records)

  # deletes a record if it's new, otherwise destroys it
  destroy_record: (record) ->
    new ember.RSVP.Promise (resolve, reject) =>
      if record.get('isNew')
        record.deleteRecord()
        resolve record
      else
        record.destroyRecord().then (saved_record) =>
          resolve saved_record

  # validate all components in an enumeration and returns whether or not all components are valid
  validate_all: (validatables, debug=false) =>
    new ember.RSVP.Promise (resolve, reject) =>
      promises = []
      validatables.forEach (validatable) =>
        promises.pushObject validatable.validate().then( => 
          return validatable.get('isValid')
        ).catch( => 
          console.log "[validate_all] Validatable is not valid:", validatable, validatable.get('errors') if debug
          return validatable.get('isValid')
        )

      ember.RSVP.Promise.all(promises).then (validities) =>
        all_valid = validities.every (is_valid) -> return is_valid
        resolve all_valid

