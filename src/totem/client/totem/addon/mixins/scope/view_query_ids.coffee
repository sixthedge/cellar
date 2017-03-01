import ember from 'ember'

export default ember.Mixin.create

  # Return a records's path by converting its type key to a path.
  record_has_viewed_id: (record, id, options={}) ->
    return false unless record and id
    viewed_ids = @get_viewed_record_path_ids(record, options)
    viewed_ids.includes parseInt(id)

  record_has_not_viewed_id: (record, id, options={}) -> not @record_has_viewed_id(record, id, options)

  # Helper methods to set viewed ids on a record.  This can be independent of the 'current_path' view ids used to filter records
  # and can be used to determine whether to send an ajax request to load data (or if the data is already loaded).
  # The viewed ids are stored in 'record._path_ids_[id_prop] = [ids]' to provide storing ids for different paths on the same record.
  # Options:
  #   viewed_current_user: [TRUE|false] true (default) means the current user id has been viewed (e.g. add to viewed_ids array)
  #   id_prop:             [string] a specific property within the record's path ids to save the viewed ids (see 'get_record_path_ids_prop' for default).
  set_viewed_record_path_ids: (record, options={}) ->
    viewed_ids   = @get_viewed_record_path_ids(record, options)
    unviewed_ids = @get_unviewed_record_path_ids(record, options)
    record.set @get_record_path_ids_prop(record, options), @concat_id_arrays(viewed_ids, unviewed_ids)  # save all viewed ids on record

  get_viewed_record_path_ids: (record, options={}) ->
    viewed_ids = @make_ids_array(record.get @get_record_path_ids_prop(record, options))
    if @is_user_ids_current_path()
      viewed_ids = @concat_id_arrays(viewed_ids, @get_current_user_id())  if options.viewed_ownerable == true
    else
      if @is_blank(viewed_ids)
        viewed_ids = @concat_id_arrays(viewed_ids, @get_ownerable_id())   if options.viewed_ownerable == true
    viewed_ids

  get_unviewed_record_path_ids: (record, options={}) ->
    viewed_ids  = @get_viewed_record_path_ids(record, options)
    current_ids = @get_current_ids() or []
    current_ids.filter (id) -> not viewed_ids.includes(id)

  unviewed_record_path_ids_blank:   (record, options={}) -> @is_blank @get_unviewed_record_path_ids(record, options)
  unviewed_record_path_ids_present: (record, options={}) -> not @unviewed_record_path_ids_blank(record, options)

  get_record_path_ids_prop: (record, options={}) ->
    path_ids = '_ts_path_ids_'  # object property that the viewed ids are saved
    record.set(path_ids, {})  unless record.get(path_ids)  # first time, set as empty object
    # The path is either:
    #  1. Property specified in: options.id_prop (manually specified id property)
    #  2. Property specified in: options.sub_action (manually specified id property)
    #  3. User data 'sub' action
    #  4. Current path
    #  5. Users path (default)
    path = options.id_prop or options.sub_action or @get_current_path() or @get_user_ids_path()
    "#{path_ids}.#{path}"
