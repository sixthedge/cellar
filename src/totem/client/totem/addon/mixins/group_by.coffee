import ember from 'ember'

export default ember.Mixin.create
  # Group an array of EMBER objects that have the same '<key>_id' value but different related values.
  # Each group property must start with the same <key> e.g. key=some_name: some_name_model, some_name_label, etc.
  # Groups are nested based on the <key> sort order.
  # The sort order must be either be:
  #   - Passed in the options key 'sort' e.g. @group_values(values, sort: ['key1', 'key2', ...].
  #   - A 'group_sort' property on the current object.
  # By default, the object will be sorted on '<key>_label' unless options 'sort_prop' is specified.

  # ### Main function to group a values array.

  group_values: (values, options={}) ->
    return [] if ember.isBlank(values)
    [sort_keys, sorted_values] = @get_group_sort_keys_and_sorted_values(values, options)
    return [] unless sort_keys
    group_obj  = ember.Object.create(content: sorted_values)
    find    = @get_group_find(sort_keys, options)
    groups     = null
    sort_objs  = null
    last_index = sort_keys.get('length') - 1
    sort_keys.forEach (key, sort_index) =>
      obj_find = find[sort_index] or "#{key}_id"
      if sort_objs
        next_objs = []
        sort_objs.forEach (obj) =>
          result = @get_group_results(obj, key, obj_find, options)
          obj.set 'content', result
          result.forEach (result_obj) =>
            result_obj.set 'is_last_group', sort_index == last_index # identify the last group for templates
            next_objs.push(result_obj)
        sort_objs = next_objs
      else
        groups    = @get_group_results(group_obj, key, obj_find, options)
        sort_objs = groups
    groups

  # ### Helpers

  get_group_results: (group_obj, key, find, options={}) ->
    result = []
    group_obj.get('content').forEach (obj) =>
      id        = @get_group_object_id(obj, key, find)
      has_group = result.findBy('id', id)
      unless has_group
        result_obj = ember.Object.create
          id:      id
          label:   obj.get("#{key}_label")
          model:   obj.get("#{key}_model")
          path:    obj.get("#{key}_path")
          content: []
        @totem_error.throw @, "GroupByMixin: group id is blank for key [#{key}].  Either add #{key}_id or #{key}_model to the values object or a find option ."  unless result_obj.get('id')?
        if options.add_key_props
          props = ember.makeArray(options.add_key_props).compact()
          for prop in props
            result_obj.set prop, obj.get("#{key}_#{prop}")
        if options.add_props
          props = ember.makeArray(options.add_props).compact()
          for prop in props
            result_obj.set prop, obj.get(prop)
        result.pushObject(result_obj)
      result.findBy('id', id).get('content').pushObject(obj)
    result

  get_group_sort_keys_and_sorted_values: (values, options) ->
    sort = options.sort or @get('group_sort')
    return [null, null] unless sort
    sort        = ember.makeArray(sort)
    sort_props  = []
    sort_orders = []
    sort_keys   = []
    first_obj   = values.get('firstObject')
    sort.forEach (sort_value) =>
      [key, order] = sort_value.split(':')
      order        = 'asc'  unless order
      @totem_error.throw @, "GroupByMixin: Sort value [#{sort_value}] must use 'asc' or 'desc' not [#{order}]."  unless order == 'asc' or order == 'desc'
      sort_prop = @get_group_sort_by(first_obj, key, options)
      sort_props.push sort_prop
      sort_orders.push order
      sort_keys.push key
    [sort_keys, @get_group_sorted_values(values, sort_props, sort_orders)]

  # Sort the values array based on the sort property and order (e.g. 'asc' or 'desc').
  get_group_sorted_values: (values, sort_props, orders) ->
    values.toArray().sort (a, b) ->
      for prop, i in sort_props
        prop_a = a.get(prop)
        prop_b = b.get(prop)
        rc     = ember.compare(prop_a, prop_b)
        rc     = (rc * -1)  if rc and orders[i] == 'desc'
        return rc if rc
      return 0

  # The default sort_by is first the <key> then '<key>_label' (if <key> does not exist in the object).
  # The sort_by options specify the property used to sort the objects.
  # A different sort_by value can be added to the 'options.sort_by'.
  #  - sort_by: {<key>: 'string'} #=> use the property name for the sort_key.
  #:            If a <key> for the sort key does not exist will use the default.
  # When a sort_by value is not found in the object, an error is raised.
  get_group_sort_by: (obj, key, options) ->
    sort_by = options.sort_by
    if sort_by
      unless typeof(sort_by) == 'object' and not ember.isArray(sort_by)
        @totem_error.throw @, "GroupByMixin: Options sort_by [#{sort_by}] must be an object."
      key_sort_by = sort_by[key]
      if key_sort_by
        unless obj.get(key_sort_by)?
          @totem_error.throw @, "GroupByMixin: Options sort_by [#{key_sort_by}] for key [#{key}] is not an object property.  Missing option add_props?"
        else
          return key_sort_by
    switch
      when obj.get(key)?                 then key
      when obj.get("#{key}_label")       then "#{key}_label"
      else
        @totem_error.throw @, "GroupByMixin: Value objects do not contain sort property for [#{key}]."

  # The default find value is <key>_id.
  # A different find value can be added to the 'options.find'.
  #  - find: 'string' #=> use this property name for the 'first' sort key.
  #  - find: [array]  #=> use the array[sort-keys-index] property name (if null|undefined uses default).
  #  - find: {<key>: 'string'} #=> use the property name for the sort_key.
  #                                  (note: transformed into an array with a null value if the sort key is not included).
  # Warning: If the find value is not a <key>_id, you must include the property with the options.add_prop.
  get_group_find: (sort_keys, options) ->
    find = options.find
    switch
      when ember.isArray(find)       then find
      when typeof(find) == 'string'  then ember.makeArray(find)
      when typeof(find) == 'object'  then sort_keys.map (key) => find[key] or null
      else []

  # The object 'group_id' is a unique identifier for this object.  Typically, it is a model id.
  # Options (in priority order):
  #  - Set a 'find' property name string in the options to get the id from the object property.
  #  - Add a '<key>_id' value to the object.
  #  - Add a '<key>_model' to the object and the key will become the model's id.
  get_group_object_id: (obj, key, find) ->
    id = obj.get(find)
    return id if id?
    obj.get("#{key}_model.id")

  # Helper that can be called during the construction of the value object.
  # Returns if a 'values object' matches an object in the array (e.g. does a per key equality check).
  # Note: This is similar to the ember 'contains' function when the objects are not the 'same' object by equality.
  contains_group_values: (array, values) ->
    array.find (obj) ->
      for own key, value of values
        return false if (obj[key] != value)
      true
