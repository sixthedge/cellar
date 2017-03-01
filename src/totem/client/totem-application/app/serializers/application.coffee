import ember from 'ember'
import ds from 'ember-data'
import totem_scope from 'totem/scope'

export default ds.JSONAPISerializer.extend

  keyForAttribute:    (key, method)            -> @underscore_string(key)
  keyForRelationship: (key, typeClass, method) -> @underscore_string(key)

  # Note: serializerIntoHash is called when serializing a record
  # (e.g. save for create and update), but not called on delete or store.find.
  serializeIntoHash: (hash, type, record, options) ->
    # console.warn {hash, type, record, options}
    totem_scope.serialize_into_hash(hash, type, record, options)  # add any auth query params
    @_super(hash, type, record, options)

  underscore_string: (val) -> (val and ember.String.underscore(val)) or ''

  # modelNameFromPayloadKey: (key) ->
  #   ukey = @underscore_string(key)
  #   # ukey = @dasherize_string(key)
  #   # console.warn 'MODEL NAME FROM PAYLOAD KEY:', key, ' #=> ', ukey
  #   ukey.singularize()
  #   # @_super(ukey)

  # dasherize_string:  (val) -> (val and ember.String.dasherize(val)) or ''

  # normalizeModelName: (key) ->
  #   console.warn 'NORMALIZE MODEL NAME:', key
  #   @_super(key)

  # extractRelationships: (mc, rh) ->
  #   rels = rh.relationships
  #   if rels
  #     for key of rels
  #       nk = key.replace('_id', '')
  #       unless nk == key
  #         # console.warn 'RELATIONSHIP', key, '#=>', nk
  #         rels[nk] = rels[key]
  #         delete(rels[key])
  #         # console.info rh
  #
  #   @_super(mc, rh)
  #
# export default ds.ActiveModelSerializer.extend
#   # Note: serializerIntoHash is called when serializing a record
#   # (e.g. save for create and update), but not called on delete or store.find.
#   serializeIntoHash: (hash, type, record, options) ->
#     totem_scope.serialize_into_hash(hash, type, record, options)  # add any auth query params
#     @_super(hash, type, record, options)
#
