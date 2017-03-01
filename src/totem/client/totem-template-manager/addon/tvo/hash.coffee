import ember from 'ember'

export default ember.Object.extend

  get_value: (key) -> @tvo.get_path_value @get_path(key)
  
  set_value: (key, value) ->
    path = @get_path(key)
    @tvo.set_path_value(path, value)
    path

  get_path: (key) -> "#{@tvo_property}.#{key}"

  # ###
  # ### Internal.
  # ###

  toString: -> 'TvoHash'
