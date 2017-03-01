import ember from 'ember'
import base  from 'totem-base/components/base'
import m_sort_by from 'totem-application/mixins/table_sort_by'

export default base.extend m_sort_by,
  tagName: ''

  admin: ember.inject.service()

  locales_data: null
  active_code:  null
  ready:        false

  sorted_locales: ember.computed.sort 'locales_data', 'sort_by'

  sort: ember.computed -> @am.get_locales_sort()

  actions:
    select_code: (code) ->
      @set 'active_code', code
      @am.set_current_locale(code)
      @set_locales()
      return

  init: ->
    @_super(arguments...)
    @am   = @get('admin')
    @i18n = @get('i18n')
    @am.reset_current_locale()
    @set_locales()
    @set_default_sort_by ['key']
    @set 'active_code', @am.get_current_locale()
    @set 'ready', true

  didInsertElement: -> @am.set_header_link_active('locales')
  willDestroy:      -> @am.reset_current_locale()

  set_locales: ->
    array = @am.get_locales()
    @set 'locales_data', array
    @set 'ready', true
