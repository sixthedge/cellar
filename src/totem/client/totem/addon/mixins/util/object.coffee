import ember from 'ember'

export default ember.Mixin.create

  add_path_objects: (obj, route) ->
    path = null
    for name in route.split('.')
      if path? then path = path + '.' + name else path = name
      obj.set path, {} unless obj.get(path)?

  set_path_value: (obj, route, value) ->
    @add_path_objects(obj, route)
    obj.set(route, value)

  model_name: (obj) -> (@is_model(obj) and obj.constructor.modelName) or null
