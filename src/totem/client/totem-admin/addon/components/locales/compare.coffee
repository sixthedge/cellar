import ember from 'ember'
import base  from 'totem-base/components/base'
import m_sort_by from 'totem-application/mixins/table_sort_by'

export default base.extend m_sort_by,
  tagName: ''

  admin: ember.inject.service()

  locales_data:        null
  active_code:         null
  active_compare_code: null
  show_missing:        false
  ready:               false

  sorted_locales: ember.computed.sort 'locales_data', 'sort_by'

  sort: ember.computed -> @am.get_locales_sort()

  actions:
    select_code: (code) ->
      @set 'active_code', code
      @set_sort_value_heading()
      @am.set_current_locale(code)
      @set_locales()
      return

    select_compare_code: (code) ->
      @set 'active_compare_code', code
      @set_sort_compare_value_heading()
      @set_locales(compare: code)
      return

    toggle_missing: ->
      missing = @toggleProperty 'show_missing'
      @set_locales({missing})
      return

  init: ->
    @_super(arguments...)
    @am = @get('admin')
    @am.reset_current_locale()
    code = @am.get_current_locale()
    @set 'active_code', code
    @set_sort_value_heading()
    @set_locales()
    @set_default_sort_by ['key']

  didInsertElement: -> @am.set_header_link_active('locales')
  willDestroy:      -> @am.reset_current_locale()

  set_locales: (options={}) ->
    compare_code = @get('active_compare_code')
    return if ember.isBlank(compare_code)
    array = @am.get_locales()
    @am.set_current_locale(compare_code)
    @am.add_locales_compare_value(compare_code, array)
    @am.set_current_locale @get('active_code')
    if options.missing
      array = array.filter (hash) => hash.missing or hash.compare_missing
    @set 'locales_data', array
    @set 'ready', true

  set_sort_value_heading: ->
    code  = @get('active_code') or ''
    value = @get('sort.value') or {}
    ember.set(value, 'text', "#{code.toUpperCase()} Value")

  set_sort_compare_value_heading: ->
    code  = @get('active_compare_code') or ''
    value = @get('sort.compare_value') or {}
    ember.set(value, 'text', "#{code.toUpperCase()} Value")
