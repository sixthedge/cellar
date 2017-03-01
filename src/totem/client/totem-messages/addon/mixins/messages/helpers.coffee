import ember from 'ember'

export default ember.Mixin.create

  is_string: (obj) -> obj and typeof(obj) == 'string'
  
  is_function: (obj) -> obj and typeof(obj) == 'function'
