import ember from 'ember'
import totem_ajax     from 'totem/ajax'
import totem_scope    from 'totem/scope'
import totem_messages from 'totem-messages/messages'

export default ember.Mixin.create

  cache: ember.Map.create()

  init: ->
    @_super(arguments...)
    @ajax           = totem_ajax
    @totem_scope    = totem_scope
    @totem_messages = totem_messages
    console.warn @

  set_instance: (instance) ->
    @store = instance.lookup('service:store')
    @error @, 'Store lookup is blank.' if ember.isBlank(@store)

  get_from_cache: (key) -> @cache.get(key)

  set_cache:    (key, records) -> @cache.set(key, records)
  delete_cache: (key)          -> @cache.delete(key)

  clear_cache: -> @cache.clear()

  cache_has: (key) -> @cache.has(key)

  toString: -> 'TotemCache'
