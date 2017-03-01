import ember from 'ember'

export default ember.Mixin.create

  # Store the ownerable values used by the rest adapter/serializer.
  ownerable_type_attr: null
  ownerable_id_attr:   null
  ownerable_type:      null
  ownerable_id:        null
  ownerable_record:    null

  # Sets the ownerable AND the current_path and current_ids as the ownerable for filters.
  # e.g. use to switch filters from users to teams or vice-versa.
  ownerable: (ownerable, options={}) ->
    @set_ownerable(ownerable, options)
    @current_path_and_ids_to_ownerable()

  # Convience function to set the ownerable and current path/ids to the current_user.
  # Same as totem_scope.ownerable(null, options) but more descriptive.
  ownerable_to_current_user: (options={}) -> @ownerable @get_current_user(), options

  # Set the current path and ids to the ownerable.
  current_path_and_ids_to_ownerable: (options={}) ->
    @set_current_path_and_ids @get_ownerable_type(), @get_ownerable_id()

  # Ownerable getters.
  get_default_ownerable_type_attr: -> 'ownerable_type'
  get_default_ownerable_id_attr:   -> 'ownerable_id'
  get_ownerable_type_attr:         -> @get('ownerable_type_attr') or @get_default_ownerable_type_attr()  # the record's attribute containing the ownerable type
  get_ownerable_id_attr:           -> @get('ownerable_id_attr')   or @get_default_ownerable_id_attr()    # the record's attribute containing the ownerable id
  get_ownerable_type:              -> @get 'ownerable_type'
  get_ownerable_id:                -> @get 'ownerable_id'
  get_ownerable_record:            -> @get('ownerable_record') or @get_current_user()

  has_ownerable:          -> @get_ownerable_type() and @get_ownerable_id()
  ownerable_is_type_user: -> @get_ownerable_type() == @get_current_user_type()

  # Set the ownerable type and ownerable id from the record (default to current user if record is null).
  # Optionally, an ownerable type and id attribute can be specified if different from 'ownerable_type' and 'ownerable_id'.
  #  * If ember-data does not resolve a polymophic into the actual record, can use 'ownerable.type' and 'ownerable.id'.
  set_ownerable: (record=null, options={}) ->
    record   ?= @get_current_user()
    type_attr = options.type_attr
    id_attr   = options.id_attr
    id_attr   = type_attr.replace('type', 'id')  if type_attr and (not id_attr)
    type      = @get_record_path(record)
    id        = record.get('id')
    @set 'ownerable_type', type
    @set 'ownerable_id', parseInt(id)
    @set 'ownerable_type_attr', type_attr
    @set 'ownerable_id_attr', id_attr
    @set 'ownerable_record', record

  # Set a record's ownerable attributes to the totem scope's ownerable type and id.
  set_record_ownerable_attributes: (record) ->
    return unless record
    type_attr = @get_ownerable_type_attr()
    id_attr   = @get_ownerable_id_attr()
    record.eachAttribute (rec_attr) =>
      switch rec_attr
        when type_attr
          record.set type_attr, @get_ownerable_type()
        when id_attr
          record.set id_attr, @get_ownerable_id()
