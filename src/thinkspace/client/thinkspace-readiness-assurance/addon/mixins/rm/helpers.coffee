import ember from 'ember'
import util  from 'totem/util'

export default ember.Mixin.create

  current_user_id:        -> @current_user.get('id')
  current_user_full_name: -> @current_user.get('full_name')

  is_function:      (fn)  -> util.is_function(fn)
  is_hash:          (obj) -> util.is_hash(obj)
  is_true_or_false: (val) -> util.is_true_or_false(val)

  stringify: (obj) -> JSON.stringify(obj)

  save_off_message: (model) -> console.info "Saving to the server is turned off (options.save_response == false).", model

  error: (args...) -> util.error(args...)

  toString: -> 'ReadinessAssuranceResponseManager:' + ember.guidFor(@)
