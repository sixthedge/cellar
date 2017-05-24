import ember       from 'ember'
import totem_error from 'totem/error'

export default ember.Mixin.create

  current_user_full_name: -> @current_user.get('full_name')

  is_function: (fn) -> typeof(fn) == 'function'
  is_object: (obj)  -> obj and typeof(obj) == 'object'
  is_hash: (obj)    -> @is_object(obj) and not ember.isArray(obj)

  is_true_or_false: (val) -> val == true or val == false

  is_for_ownerable: (id='', type='') ->
    # ID may be a string in the case of a UUID.
    (@ownerable_id.toString() == id.toString()) && (@ownerable_type.toString() == type.toString()) 

  stringify: (obj) -> JSON.stringify(obj)

  save_off_message: (model) -> console.info "Saving to the server is turned off (options.save_response == false).", model

  error: (args...) ->
    message = args.shift() or ''
    console.error message, args if ember.isPresent(args)
    totem_error.throw @, message

  toString: -> 'ReadinessAssuranceResponseManager:' + ember.guidFor(@)
