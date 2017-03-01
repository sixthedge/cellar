import ember from 'ember'
import util  from 'totem/util'
import tcl   from 'totem-config/locales'

export default ember.Mixin.create

  get_current_locale: -> @i18n.get('locale')
  set_current_locale:   (code) -> tcl.set_current_locale(code)
  reset_current_locale: (code) -> tcl.set_current_locale(tcl.get_default_code())

  get_locales_sort: ->
    sort_configs =
      key:           {id: 'key', sort: 'sort_key', text: 'Locale Key'}
      value:         {id: 'value', sort: 'sort_value', text: 'Value'}
      count:         {id: 'count', sort: 'count', text: 'Cnt'}
      cnt_key:       {id: 'cnt_key', sort: 'sort_cnt_key', text: 'Cnt Key'}
      compare_value: {id: 'compare_value', sort: 'sort_compare_value', text: 'Compare Value'}

  get_locales: ->
    keys  = @get_locales_keys()
    array = []
    for key, count_hash of keys
      hash               = {}
      hash.key           = key
      hash.compare_value = ''
      if util.is_hash(count_hash)
        cnt_key      = count_hash.cnt_key
        count        = if ember.isBlank(count_hash.count) then 0 else count_hash.count
        hash.value   = @i18n.t(cnt_key, count: count)
        hash.count   = count
        hash.cnt_key = cnt_key
      else
        hash.value    = @i18n.t(key)
        hash.count    = ''
        hash.cnt_key = ''
      hash.missing = @is_locales_missing(hash)
      @make_locales_sortable(hash)
      array.push(hash)
    array

  get_locales_keys: ->
    locales     = tcl.current_locale or {}
    locale_keys = util.hash_keys(locales).sort()
    keys        = {}
    for key in locale_keys
      count = @get_locales_count(key)
      if ember.isPresent(count)
        cnt_key       = @get_locales_cnt_key(key)
        keys[key]      = {cnt_key, count}
        keys[cnt_key] = null if ember.isBlank(keys[cnt_key])
      else
        keys[key] = null
    keys

  get_locales_cnt_key: (key) ->
    parts = key.split('.')
    parts.pop()
    parts.join('.')

  get_locales_count: (key) ->
    return 1 if util.ends_with(key, '.one')
    return 2 if util.ends_with(key, '.other')
    null

  is_locales_missing: (hash) -> if (hash.value or '').toString().match('Missing translation') then true else false

  make_locales_sortable: (hash) ->
    hash.sort_key     = (hash.key or '').toString().toLowerCase()
    hash.sort_value   = (hash.value or '').toString().toLowerCase()
    hash.sort_cnt_key = (hash.cnt_key or '').toString().toLowerCase()

  add_locales_compare_value: (code, array) ->
    compare_array = @get_locales()
    compare_keys  = util.hash_keys @get_locales_keys()
    keys          = array.mapBy('key')
    all_keys      = compare_keys.concat(keys)
    for key in all_keys
      hash         = array.findBy('key', key)
      compare_hash = compare_array.findBy('key', key)
      switch
        when ember.isBlank(hash)
          compare_hash.compare_value = compare_hash.value
          compare_hash.value         = 'Missing translation'
          compare_hash.missing       = true
          compare_hash.sort_value    = 'zzzzzz'
          array.push(compare_hash)
        when ember.isBlank(compare_hash)
          hash.compare_value      = 'Missing translation'
          hash.compare_missing    = true
          hash.sort_compare_value = 'zzzzzz'
        else
          hash.compare_value      = compare_hash.value
          hash.sort_compare_value = hash.compare_value.toString().toLowerCase()
