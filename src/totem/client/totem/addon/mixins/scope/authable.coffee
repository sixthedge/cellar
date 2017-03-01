import ember from 'ember'

export default ember.Mixin.create

  authable_type: null
  authable_id:   null

  get_authable_type: -> @get 'authable_type'
  get_authable_id:   -> @get 'authable_id'
  set_authable:      (record) -> @authable(record)

  has_authable: -> ember.isPresent(@get_authable_id()) and ember.isPresent(@get_authable_type())

  authable: (record) ->
    return unless record
    type = @get_record_path(record)
    id   = record.get('id')
    @set 'authable_type', type
    @set 'authable_id', id

  record_authable_match_authable: (record, authable=null) ->
    return false unless record
    record_authable_type = @rails_polymorphic_type_to_path(record.get 'authable_type')
    record_authable_id   = record.get('authable_id')
    if authable
      authable_type = @get_record_path(authable)
      authable_id   = authable.get('id')
    else
      authable_type = @get_authable_type()
      authable_id   = @get_authable_id()
    record_authable_type == authable_type and parseInt(record_authable_id) == parseInt(authable_id)

