import ember from 'ember'

export default ember.Mixin.create

  # Filter records based on current path and ids.
  # If the current_path is not set, default to the users path.
  can_view_record_current_path_id: (record) ->
    return false unless record
    path = @get_current_path() or @get_user_ids_path()
    if path == @get_user_ids_path()
      @can_view_record_user_id(record)  # users have special conditions e.g. allows matching current user id
    else
      return false if @record_is_deleted(record)
      id_attr = @get_path_id_attr(path)
      @valid_record_path_type(path, record) and @can_view_path_id(path, record.get(id_attr))

  # Filter function for users.
  # A common use of filters is to filter on the current user, therefore, if the users' path ids are blank,
  # defaults to matching the current_user id and allows filtering on current user before any paths/ids are set.
  # This function may be called by the totem_associations' filter function when filter: 'users' is used,
  # so must be capable to be called with just the record.
  can_view_record_user_id: (record) ->
    return false unless record
    return false if @record_is_deleted(record)
    path    = @get_user_ids_path()
    id_attr = @get_path_id_attr(path)
    id      = record.get(id_attr)
    return false unless id
    return false unless @valid_record_path_type(path, record)
    ids = @get_path_ids(path)
    unless ids
      current_user_id = @get_current_user_id()
      ids = (current_user_id and [current_user_id]) or []
    id in ids

  # Record's polymorphic 'type' value must match the path.
  valid_record_path_type: (path, record) ->
    type_attr = @get_path_type_attr(path)
    return true unless type_attr  # if type attr is blank (manually set to blank), no record type is checked and is valid
    type = record.get(type_attr)
    return false unless type
    path == @rails_polymorphic_type_to_path(type)
