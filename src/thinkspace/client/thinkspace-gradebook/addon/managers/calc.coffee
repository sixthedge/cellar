import ember from 'ember'

export default ember.Object.create

  values: (value_array) ->
    vals           = ember.makeArray(value_array)
    result         = {}
    result.count   = @count(vals)
    result.total   = @total(vals)
    result.average = @average(result.total, result.count)
    result.median  = @median(vals)
    result

  count: (value_array) -> ember.makeArray(value_array).get('length')

  count_uniq: (value_array) -> ember.makeArray(value_array).uniq().get('length')

  total: (value_array, total=0) ->
    total = total + value for value in ember.makeArray(value_array)
    total

  average: (total, count) -> (count and (total / count)) or 0

  median: (value_array) ->
    sort_values = ember.makeArray(value_array).sort()
    half        = Math.floor(sort_values.length / 2)
    return sort_values[half]  if sort_values.get('length') % 2 
    (sort_values[half-1] + sort_values[half]) / 2.0

  count_uniq_key_values: (hash_array, key) -> ember.makeArray(hash_array).mapBy(key).uniq().get('length')

  non_zero_values: (value_array) -> @values(value_array.filter (value) -> value > 0)

  count_non_zero_uniq_key_values: (hash_array, non_zero_key, key) ->
    non_zero_hash_array = ember.makeArray(hash_array).filter (hash) -> hash.get(non_zero_key) > 0
    @count_uniq_key_values(non_zero_hash_array, key)
