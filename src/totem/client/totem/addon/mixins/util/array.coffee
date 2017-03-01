import ember from 'ember'

export default ember.Mixin.create

  flatten_array: (array) ->
    flattened = []
    for element in array
      if @is_array(element)
        flattened = flattened.concat @flatten_array element
      else
        flattened.push element
    flattened

  string_array_to_numbers: (array) ->
    array.forEach (string, index) => array[index] = parseInt(string)
    array
