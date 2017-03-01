import ember from 'ember'

export default ember.Mixin.create
  # Contains all paths and ids that are used in filters; path_ids[path-name] = [ids].

  path_ids: {}

  get_path_ids: (path) -> @get "path_ids.#{path}"

  # Set the path ids and send an ids change notification.
  set_path_ids: (path, ids) ->
    path and @set "path_ids.#{path}", @make_ids_array(ids)
    @notify_path_ids_property_change()

  reset_all_ids:         -> @set 'path_ids', {}
  reset_path_ids: (path) -> @set_path_ids path, null

  notify_path_ids_property_change: -> @notifyPropertyChange('path_ids')

  path_ids_blank:   (path) -> path and @is_blank(@get_path_ids path)
  path_ids_present: (path) -> not @path_ids_blank(path)

  can_view_path_id: (path, id) ->
    return false unless (path and id)
    ids = @get_path_ids(path) or []
    id in ids

  # Map of each path to the filter attribute(s) on a record.  Typically, this will be the same as the ownerable
  # type and id attributes, but if different (e.g. want to filter on just 'user_id'), it can be set for a path.
  # The path's type and id attributes are set as: path_to_attrs.path-name = {type: type-attr, id: id-attr}.
  # 'Get' returns the specific path's type/id or will default to the 'ownerable' type/id (either is set or will be the default).
  path_to_attrs: {}
  get_path_type_attr: (path=null) -> (path and @get "path_to_attrs.#{path}.type") or @get_ownerable_type_attr()
  get_path_id_attr:   (path=null) -> (path and @get "path_to_attrs.#{path}.id")   or @get_ownerable_id_attr()
  set_path_attrs: (path, attrs)   -> path and (@set "path_to_attrs.#{path}", attrs)

  # ###
  # ### Current path and ids.
  # ###

  # Current path is used to return ids from the 'path_ids' object e.g. path_ids[current_path].
  # The current path ids are used by the record association filters.
  # Typically, the current path (and ids) are set when setting the 'ownerable' but
  # can be manually set to any path/ids.
  current_path: null

  get_current_path: -> @get('current_path')
  get_current_ids:  -> @get_path_ids @get_current_path()

  set_current_path: (path=null) -> @set 'current_path', path

  # Current ids represent the ids in path_ids[current_path] (e.g. not a current_ids property).
  # Anytime the 'path_ids' are set, an ids change notification is sent.
  set_current_ids: (ids) -> @set_path_ids(@get_current_path(), ids)

  # Set the current path then set path_ids[current_path] = ids.
  set_current_path_and_ids: (path, ids) ->
    @set_current_path(path)
    @set_current_ids(ids)

  # Change the current path value.
  # If path is already the current path then return, else since a path change, notify the ids have changed.
  change_current_path: (path=null) ->
    return if @get_current_path() == path
    @set_current_path(path)
    @notify_path_ids_property_change()

  current_path_blank:   -> not @get_current_path()
  current_path_present: -> not @current_path_blank()
  current_ids_blank:    -> not @path_ids_blank(@get_current_path())
  current_ids_present:  -> not @current_ids_blank()

  # ###
  # ### User convience functions.
  # ###

  # Users are the typical case and these functions are conviences to the 'current' path/ids functions.

  # Computed property that templates can use to test if user ids are blank e.g. whether viewing
  # a user that is not the current user (user ids = [current user id] is also considered blank).
  view_user_ids_blank: ember.computed 'path_ids', 'current_user_id', -> @is_user_ids_current_user()

  # Alias computed property for 'view_user_ids_blank'.
  view_user_is_current_user: ember.computed.reads 'view_user_ids_blank'

  # The users' path will be created from the current_user if not populated.
  # It has many references so create once and store it rather than at each request.
  user_ids_path: null
  get_user_ids_path: -> @get('user_ids_path') or @set_user_ids_path()
  set_user_ids_path: (user=@get_current_user()) ->
    @set 'user_ids_path', @get_record_path(user)
    @get 'user_ids_path'

  get_user_ids: -> @get_path_ids @get_user_ids_path()

  is_user_ids_current_path: -> @current_path_blank() or @get_current_path() == @get_user_ids_path()

  # Set the user's path to filter on a single attribute (e.g. 'user_id') when does not have ownerable polymorphic.
  set_user_ids_path_attr: (attr='user_id') ->
    @set_path_attrs @get_user_ids_path(), {id: attr}

  is_user_ids_current_user: ->
    ids = @get_user_ids()
    return true unless ids  # if user ids have not been set yet, then is the current user
    ids.get('length') == 1 and ids.objectAt(0) == @get_current_user_id()

