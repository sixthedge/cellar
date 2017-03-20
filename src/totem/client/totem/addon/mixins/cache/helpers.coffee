import ember from 'ember'
import util  from 'totem/util'

export default ember.Mixin.create

  is_reload:  (options) -> util.is_hash(options) and options.reload == true
  not_reload: (options) -> not @is_reload(options)

  can_get_from_cache: (key, options) -> @not_reload(options) and @cache_has(key)

  cache_each_record: (model_name, records) ->
    return unless ember.isArray(records)
    records.forEach (record) =>
      id  = record.get('id')
      key = @get_record_cache_key(model_name, id)
      @set_cache(key, record)

  get_record_cache_key: (model_name, id) -> "#{model_name}/#{id}"

  get_query_cache_key: (model_name, query, options={}) ->
    str_query = @stringify(query)
    key       = "#{model_name}/query:#{str_query}"
    return key unless util.has_keys(options)
    str_options = @stringify(options)
    key + "/options:#{str_options}"

  add_filter_to_query: (query, filter) ->
    query.filter = @stringify(filter)
    query

  add_sort_to_query: (query, sort) ->
    query.sort = @stringify(sort)
    query

  get_filter_array: (method, values) ->
    [{method: method, values: values}]

  stringify: (obj) -> util.stringify(obj)

  deprecation: (message) -> console.warn "[tc] DEPRECATION: #{message}"

  warn:  (args...) -> util.warn(@, args...)
  error: (args...) -> util.error(@, args...)
