import ember from 'ember'
import util  from 'totem/util'
import tc    from 'totem-config/configs'

class TotemConfigNamespaceMap

  constructor: ->
    @map = {
      namespaces:        {}
      type_to_namespace: {}
    }
    @process()
    @validate_integrity()

  process: ->
    ns_array = tc.get_ns()
    return if ember.isBlank(ns_array)
    for hash in ns_array
      @error "NS is not a hash.", hash  unless util.is_hash(hash)

      namespaces = hash.namespaces or {}
      @error "NS key 'namespaces' is not a hash."  unless util.is_hash(namespaces)
      for ns, val of namespaces
        @error "NS namespace is not a string.", hash          unless util.is_string(ns)
        @error "NS namespace value is not a string.", hash    unless util.is_string(val)
        ns_val = @map.namespaces[ns]
        if ember.isPresent(ns_val)
          @error "NS namespaces '#{ns}' is a duplicate.", hash  unless ns_val == val
        else
          @map.namespaces[ns] = val

      type_to_namespace = hash.type_to_namespace or {}
      @error "NS key 'type_to_namespace' is not a hash.", hash  unless util.is_hash(type_to_namespace)
      for type, ns of type_to_namespace
        @error "NS type_to_namespace type is not a string.", hash       unless util.is_string(type)
        @error "NS type_to_namespace namespace is not a string.", hash  unless util.is_string(ns)
        @error "NS type_to_namespace '#{type}' is a duplicate.", hash   if ember.isPresent(@map.type_to_namespace[type])
        @map.type_to_namespace[type] = ns

  validate_integrity: ->
    for type, ns of @map.type_to_namespace
      @error "Namespace '#{ns}' for type '#{type}' does not exist."  if ember.isBlank(@map.namespaces[ns])

  # ###
  # ### Helpers.
  # ###

  error: -> util.error(@, arguments...)

  toString: -> 'TotemConfigNamespaceMap'

export default new TotemConfigNamespaceMap
