import ember from 'ember'

export default ember.Mixin.create

  # Return either a record or a string in the ember expected format.
  standard_record_path: (path_or_record) ->
    if @is_string(path_or_record) then @rails_polymorphic_type_to_path(path_or_record) else @get_record_path(path_or_record)

  # Convert a rails polymorphic model type 'attribute' to a path e.g. Some::Module::Model -> some/module/model
  rails_polymorphic_type_to_path: (type) -> type.underscore().replace(/::/g,'/')

  record_is_deleted: (record) -> record.get('isDeleted') or record.get('isDestroyed') or record.get('isDestroying')

  # Return a record's type key to use in a store.find() or model_type.
  record_type_key:   (record) -> @record_model_name(record) # backward compatibility
  record_model_name: (record) -> record.constructor.modelName

  # Return a model class from a string that has the 'model_class.typeKey' set.
  # The 'store.modelFor' will normalize the string, so both a path (e.g. my/namespace/path/model)
  # or a model name (e.g. App.My.Namespace.Path.Model) will work.
  model_class_from_string: (string) ->  @get_store().modelFor(string)

  model_class_type_key:   (model_class) ->  @model_class_model_name(model_class) # backward compatibility
  model_class_model_name: (model_class) ->  ember.get(model_class, 'modelName')

  # Return a records's path by converting its model name to a path.
  get_record_path: (record) -> record and @record_model_name(record).underscore().replace(/\./g,'/')

  # Return array of integer ids.
  make_ids_array: (ids) ->
    ids = ember.makeArray(ids).map (id) -> parseInt(id) or null
    ids.compact()

  is_blank:    (v)  -> ember.isBlank(v)
  is_present:  (v)  -> ember.isPresent(v)
  is_string:   (v)  -> v  and typeof v  == 'string'
  is_function: (fn) -> fn and typeof fn == 'function'

  # Return new concatenated id array; converts ids to integers.
  # Array params can be arrays or a string|integer (if not array, converted to an integer as a single element array)
  concat_id_arrays: (array_1, array_2) ->
    array   = []
    array_1 = @make_ids_array(array_1)
    array_2 = @make_ids_array(array_2)
    array_1.forEach (value) -> array.push value
    array_2.forEach (value) -> array.push value
    array.uniq()

