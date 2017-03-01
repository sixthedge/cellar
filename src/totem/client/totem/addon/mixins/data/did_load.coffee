import ember from 'ember'

export default ember.Mixin.create

  # When a model includes totem_data, the ability/metadata records may not
  # be in the store when the model (e.g. model's totem_data mixin) is initialized
  # even when the json payload includes the ability/metadata records.
  # This will call the model's totem_data refresh method to update the data.
  # Note: Any components that use this data must be implemented via a computed
  # property that observes the model.can.prop-name.

  didLoad: -> @totem_data_refresh_model_data_name()

  totem_data_refresh_model_data_name: ->
    unless @data_name
      console.error "Authorization model 'data_name' property is blank.", @
      return
    [type, id] = @totem_data_get_type_and_id_for_model()
    return unless type and id
    @totem_data_model_refresh(type, id)

  totem_data_get_type_and_id_for_model: ->
    rec_id = @get('id')
    [model, ownerable] = rec_id.split('::', 2)
    model.split('.', 2)

  totem_data_model_refresh: (type, id) ->
    record = @store.peekRecord(type, id)
    return unless record
    return unless record.totem_data
    data_mod = record.totem_data[@data_name]
    return unless data_mod
    data_mod.refresh()
