import ember from 'ember'
import ns from 'totem/ns'
# #**T**otem **A**synchronous **F**iltering

# @TODO need a way to specify between AND'd inter-filters and OR'd intra-filters

# ## API
# - `query`
# - `add_filter`
# - `remove_filter`
# - `remove_all_filters`
# - `add_bound_filter`
# - `remove_bound_filter`
# - `remove_all_bound_filters`


export default ember.Service.extend
  filters:       {}
  bound_filters: {}
  is_querying: false # watch this property for the status of the query

  # Requests a payload endpoint with optional filters
  #
  # @public
  # @method query
  # @param {Array} collection set of objects to run the filters on
  #
  # @return {Array} results resulting set of objects filtered out
  query: (collection) ->
    collection = @make_array collection
    @set_is_querying()
    new ember.RSVP.Promise (resolve, reject) =>
      @process_bound_filters()
      filters = @get('filters')
      resolve collection if ember.isEmpty filters
      promises = @make_array()
      for property, value of filters
        values = @make_array value
        promises.pushObject @filter_by(collection, property, values)
      ember.RSVP.Promise.all(promises).then (results) =>
        results = @intersection results
        @reset_is_querying()
        resolve results

  # Adds filter key and options to the pending query
  #
  # @public
  # @method add_filter
  # @param {String} key Property to filter against for each member
  # @param  {Object} values Value or values for which the filter should return true
  #
  # @return {Hash} The full set of current filters
  add_filter: (key, values, options={}) ->
    return if not key
    @clear() if options['clear']
    filters      = @get('filters') || {}
    filters[key] = values
    @set 'filters', filters
    return filters

  # Removes the filter by key from the pending query
  #
  # @public
  # @method remove_filter
  # @param {String} key property to filter against for each member
  #
  # @return {Hash} The full set of current filters
  remove_filter: (key) ->
    return if not key
    filters = @get('filters') || {}
    delete filters[key]
    @set 'filters', filters
    return filters

  # Removes all filters from the pending query
  #
  # @public
  # @method remove_filter
  # @alias clear

  remove_all_filters: ->
    filters = @get('filters')
    for property, value of filters
      @remove_filter property

  # @public
  # @method clear
  clear: -> @remove_all_filters()


  # Adds filter with a context that determines if the filter is active
  #
  # @public
  # @method add_bound_filter
  # @param {String} the property to filter against for each member
  # @param {String} the name of the property on the context which retrieves the values for which the filter should return true
  # @param {String} the ember object to retrieve the values from, typically a controller/view/component
  #
  # @returns {Hash} The current filter set
  add_bound_filter: (key, values_property, context) ->
    return if not key and values_property and context
    bound_filters = @get('bound_filters') || {}
    bound_filters[key] =
      context: context
      values_property: values_property
    @set 'bound_filters', bound_filters
    return bound_filters


  # Removes a bound filter from the query
  #
  # @public
  # @method remove_bound_filter
  # @param {String} the property to filter against for each member
  #
  # @return {Hash} the current filter set
  remove_bound_filter: (key) ->
    return if not key
    bound_filters = @get('bound_filters') || {}
    delete bound_filters[key]
    @set 'bound_filters', bound_filters
    return bound_filters

  # Removes all bound filters from the query
  #
  # @public
  # @method remove_all_bound_filters
  remove_all_bound_filters: ->
    bound_filters = @get('bound_filters')
    for property, value of bound_filters
      @remove_bound_filter property


  process_bound_filters: ->
    for key, bound_filter of @get('bound_filters')
      context         = bound_filter.context
      values_property = bound_filter.values_property
      values          = context.get(values_property)
      @add_filter key, values

  # proxies for filter_by_relationship || filter_by_property depending on the property type
  #
  # @private
  # @method filter_by
  filter_by: (collection, property, values, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      if (ember.isEmpty(collection) or ember.isEmpty(values))
        resolve(collection)
      else
        type = @get_property_type collection, property
        switch type
          when 'relationship'
            @filter_by_relationship(collection, property, values, options).then (results) =>
              resolve results
          when 'property'
            @filter_by_property(collection, property, values, options).then (results) =>
              resolve results
          else
            resolve(collection)
  
  # Called by filter_by to resolve based on a models relationship
  #
  # @private
  # @method filter_by_relationship
  filter_by_relationship: (collection, relationship, values, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      if (ember.isEmpty(collection) or ember.isEmpty(values))
        resolve(collection) 
      else
        ember.RSVP.filter(collection, (member) =>
          member.get(relationship).then (related_records) =>
            related_records = @make_array related_records
            return related_records.any (related_record) ->
              values.contains(related_record)
        ).then (results) =>
          resolve results

  # Called by filter_by to resolve based on a models property
  #
  # @private
  # @method filter_by_property
  filter_by_property: (collection, property, values, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      resolve collection if ember.isEmpty collection or ember.isEmpty values
      results = []
      collection.forEach (member) =>
        value = member.get(property)
        results.pushObject(member) if values.contains(value)
      resolve results

  # ## HELPERS
  # Determines if the member property is indeed a property or an association
  #
  # @private
  # @method get_property_type
  get_property_type: (collection, property) ->
    return unless ember.isPresent(property)
    return if ember.isEmpty collection
    member = collection.get('firstObject')
    val    = member.get(property)
    return unless ember.isPresent(val) or ember.isArray(val)
    return if val.then? then 'relationship' else 'property'

  # Gets the intersection of n arrays
  #
  # @private
  # @method intersection
  intersection: (arrays) ->
    result = @make_array(arrays.get('firstObject'))
    for array in arrays
      result = ember.EnumerableUtils.intersection result, @make_array(array)
    return result

  # Called by filter_by to resolve based on a models relationship
  #
  # @private
  # @method difference
  difference: (array1, array2) ->
    array1 = @make_array(array1)
    array2 = @make_array(array2)
    result = @make_array(array1)
    for element1 in array1
      result.removeObject element1 if array2.contains(element1)
    return result

  # Flattens a two-dimensional array into a single one-dimensional array, duplicates are not removed
  #
  # @private
  # @method flatten
  flatten: (arrays) ->
    result = @make_array()
    for array in arrays
      result = result.concat @make_array(array)
    return result

  # Compacts an array of arrays, removing all undefined and null elements
  #
  # @private
  # @method compress
  compress: (arrays) ->
    arrays = @make_array(arrays).compact()
    for arr, i in arrays
      arrays[i] = @make_array(arr).compact()
    return arrays

  # shuffles an array, randomizing the order of the elements
  #
  # @private
  # @method shuffle
  # => the total number of swaps performed is n * no_of_swaps
  # => the greater the number of swaps, the more randomized the elements are
  shuffle: (array, no_of_swaps=2) ->
    array  = @make_array(array)
    length = array.get('length')
    for [0..(length * no_of_swaps)]
      swap_i_1 = Math.round(Math.random()*(length - 1))
      swap_i_2 = Math.round(Math.random()*(length - 1))
      unless swap_i_1 == swap_i_2
        tmp = array.objectAt(swap_i_1)
        array[swap_i_1] = array[swap_i_2]
        array[swap_i_2] = tmp
    return array

  # extends the functionality of ember.makeArray to also include transforming DS.ManyArrays
  #
  # @private
  # @method make_array
  make_array: (val) ->
    return ember.makeArray() unless ember.isPresent val
    val = val.toArray() if val.toArray?
    return ember.makeArray val

  set_is_querying: ->
    @set 'is_querying', true

  reset_is_querying: ->
    @set 'is_querying', false
