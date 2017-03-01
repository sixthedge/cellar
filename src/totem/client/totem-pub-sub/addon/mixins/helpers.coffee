import ember from 'ember'
import util  from 'totem/util'
import totem_scope from 'totem/scope'

export default ember.Mixin.create

  get_totem_scope: -> totem_scope

  add_ownerable_to_query: (query) -> @get_totem_scope().add_ownerable_to_query(query)
  add_authable_to_query:  (query) -> @get_totem_scope().add_authable_to_query(query)  if @get_totem_scope().get_authable_id()

  model_path: (record) -> @get_totem_scope().get_record_path(record)

  is_string: (obj)  -> util.is_string(obj)
  is_hash:   (obj)  -> util.is_hash(obj)
  is_array:  (obj)  -> util.is_array(obj)
  is_record: (obj)  -> util.is_model(obj)
  is_function: (fn) -> util.is_function(fn)

  is_active:   (obj) -> not @is_inactive(obj)
  is_inactive: (obj) -> util.is_destroyed(obj)

  get_object_keys: (obj) -> util.object_keys(obj)

  # Perform a shallow compare of object values of strings and arrays (e.g. does not compare nested objects).
  objects_equal: (obja, objb) ->
    obja_keys = @get_object_keys(obja)
    objb_keys = @get_object_keys(objb)
    if ember.compare(obja_keys, objb_keys) == 0
      contains = true
      for k, v of objb
        if ember.isArray(v)
          contains = false unless ember.compare(obja[k], v) == 0
        else
          contains = false unless v == obja[k]
      return objb if contains
    false

  stringify: (obj) -> JSON.stringify(obj)

  error: (messages...) ->
    messages.unshift "#{@toString()}: "
    throw new Error(messages.join("\n"))

  # ###
  # ### Map Helpers.
  # ###

  get_key_map: (map, key) ->
    return map.get(key) if map.has(key)
    map.set key, ember.Map.create()
    map.get(key)

  get_key_map_value_array: (map, key) ->
    array = map.get(key)
    return array if @is_array(array)
    map.set key, []
    map.get(key)

  # ###
  # ### Options Helpers.
  # ###

  get_options_rooms:            (options) -> @get_options_array(options, 'rooms', 'room')
  get_options_events:           (options) -> @get_options_array(options, 'events', 'event')
  get_options_callbacks:        (options) -> @get_options_array(options, 'callbacks', 'callback')
  get_options_room_type:        (options) -> options and options.room_type
  get_options_room_event:       (options) -> options and options.room_event
  get_options_room_observer:    (options) -> options and options.room_observer
  get_options_source:           (options) -> options and options.source

  get_options_array: (options, keys...) ->
    return null unless options
    for key in keys
      values = options[key]
      return ember.makeArray(values) if values
    null

  # ###
  # ### Data Helpers.
  # ###

  get_data_auth_key: (data) -> data and data.auth_key

  toString: -> 'TotemPubSub'
