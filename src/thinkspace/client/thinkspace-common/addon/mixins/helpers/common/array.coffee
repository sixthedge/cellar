import ember from 'ember'

export default ember.Mixin.create

  taf: ember.inject.service()

## ###
## Array Helpers
## ###

  replace_at: (array, index, obj) =>
    array.removeObject(obj)
    array.insertAt(index, obj)
    array

  push_unless_contains: (array, obj) =>
    array.pushObject(obj) unless array.contains(obj)

  # TAF helpers
  flatten: (arrays) -> @get('taf').flatten(arrays)
  intersection: (arrays) -> @get('taf').intersection(arrays)
  difference: (array1, array2) -> @get('taf').difference(array1, array2)

  # filter by multiple conditions
  filter_by: (array, conditions) ->
    return array unless ember.isPresent conditions
    for k,v of conditions
      array = array.filterBy k, v
    return array

  # find by multiple conditions
  find_by: (array, conditions) ->
    return array unless ember.isPresent conditions
    for k,v of conditions
      array = array.filterBy k, v
    return array.get('firstObject')

  # gets array elements whose property value is contained in values
  where_in: (array, property, values) ->
    array.filter (element) -> values.contains(element[property])

  minimum_for_property: (records, property) ->
    records.sortBy(property).get('firstObject')

  maximum_for_property: (records, property) ->
    records.sortBy(property).get('lastObject')

  # returns a shallow copy of a provided array
  duplicate_array: (array) ->
    copy = []
    array.forEach (a) => copy.pushObject(a)
    copy    

  # gets a has_many relationship from from a record and calls toArray()
  has_many_to_array: (context, property) ->
    new ember.RSVP.Promise (resolve, reject) =>
      context.get(property).then (records) =>
        resolve(records.toArray())

  # adds or removes objects in array1 to match array2
  sync_array: (array1, array2) ->
    array1.forEach (a) =>
      array1.removeObject(a) unless array2.contains(a)
    array2.forEach (b) =>
      array1.pushObject(b) unless array1.contains(b)

  get_each: (model, relationship) ->
    new ember.RSVP.Promise (resolve, reject) =>
      promises = model.getEach(relationship)
      ember.RSVP.Promise.all(promises).then (results) =>
        resolve results

  remove_objects_with_value: (array, key, value) ->
    array.forEach (element) =>
      array.removeObject(element) if element[key] == value
    array

