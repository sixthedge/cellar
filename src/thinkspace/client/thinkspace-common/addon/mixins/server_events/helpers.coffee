import ember from 'ember'
import util  from 'totem/util'

export default ember.Mixin.create

  load_records_into_store: (value) ->
    new ember.RSVP.Promise (resolve, reject) =>
      records = value.records
      return resolve() if ember.isBlank(records)
      @tc.push_payload(records)
      resolve()

  find_record: (type, id) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve(null) if ember.isBlank(type) or ember.isBlank(id)
      record = @tc.peek_record(type, id)
      return resolve(record) if ember.isPresent(record)
      @tc.find_record(type, id).then (record) =>
        resolve(record)

  get_data_rooms: (data) ->
    return null unless util.is_hash(data)
    data.room or data.rooms

  get_socketio_event_room: (event) ->
    return null unless util.is_string(event)
    event.replace(/^server:/,'').replace(/\/server_event$/,'')

  warn:  (args...) -> util.warn(@, args...)
  error: (args...) -> util.error(@, args...)
