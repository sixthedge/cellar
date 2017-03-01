import ember from 'ember'
import ds    from 'ember-data'
import {env} from 'totem-config/config'

export default ember.Mixin.create

  is_development: -> env.environment == 'development'

  is_integer:  (num) -> num and "#{num}".match(/^\d+$/)
  is_number:   (num) -> Number(num).toString() != 'NaN'

  is_undefined: (val) -> typeof(val) == 'undefined'
  is_null:      (val) -> val == null

  is_string:   (obj) -> obj and typeof(obj) == 'string'
  is_hash:     (obj) -> obj and typeof(obj) == 'object' and not ember.isArray(obj)
  is_function: (fn)  -> fn  and typeof(fn) == 'function'

  is_changeset: (obj) -> @is_hash(obj) and obj.__changeset__ == '__CHANGESET__'
  is_component: (obj) -> @is_get(obj) and obj.get('isComponent') == true
  is_get:       (obj) -> @is_object_function(obj, 'get')

  is_mixin:   (obj) -> obj and obj instanceof ember.Mixin
  is_promise: (obj) -> obj and obj instanceof ember.RSVP.Promise
  is_jquery:  (obj) -> obj and jQuery and obj instanceof(jQuery)

  is_model:      (obj)       -> obj and obj instanceof ds.Model
  is_model_type: (obj, type) -> @is_string(type) and @model_name(obj) == type

  is_object_function: (obj, fn) -> @is_hash(obj) and @is_string(fn) and @is_function(obj[fn])

  is_destroyed: (obj) -> @is_get(obj) and (obj.get('isDestroyed') or obj.get('isDestroying'))

  # is_array: (obj) -> obj and ember.isArray(obj) # does not catch: x={length: 1}; ember.isArray(x) #=> true
  is_array: (obj) ->
    return false  unless obj
    return true   if (Array.isArray && Array.isArray(obj))
    return true   if ( (obj.length != undefined) && typeof(obj) == 'object' )
    return false
