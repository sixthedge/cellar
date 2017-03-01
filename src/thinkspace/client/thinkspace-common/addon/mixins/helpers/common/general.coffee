import ember from 'ember'

export default ember.Mixin.create

## ###
## General Helpers
## ###


  # prints more detailed console.log
  lg: (context=true, args...) ->
    if context 
      console.trace @toString(), args...
    else
      console.trace args...

  # returns true if all values within the provided array are present, otherwise false
  all_present: (values) ->
    for value in values 
      return false unless ember.isPresent(value)
    return true

