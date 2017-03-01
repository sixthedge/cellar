import ember from 'ember'

export default ember.Helper.helper ([str, count], options={}) ->
  return ''  if ember.isBlank(str) or typeof(str) != 'string'
  return str if ember.isBlank(count)
  n = if ember.isArray(count) then count.length else count
  n = parseInt(n)
  return str if n.toString() == 'NaN'
  if n > 1 then str.pluralize() else str
