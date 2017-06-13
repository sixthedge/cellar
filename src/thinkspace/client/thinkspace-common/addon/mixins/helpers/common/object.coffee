import ember from 'ember'

export default ember.Mixin.create

## ###
## Object Helpers
## ###



  # iterates an object to get the key for a provided value
  get_key_for_value: (obj, val) ->
    for k of obj
      return k if obj[k] == val
    return undefined

  # returns an array of the values of an object
  get_values: (obj) ->
    a = []
    for k, v of obj
      a.push v
    a

  # returns whether or not an object is blank (has no keys)
  is_empty_object: (obj) ->
    ember.keys(obj).length == 0
