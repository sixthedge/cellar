import ember from 'ember'
import base  from 'totem-base/components/base'

export default base.extend
  tagName: ''

  i18n: ember.inject.service()

  locale_codes: ember.computed -> @get('i18n').get('locales').sort()

  actions:
    select: (code) -> @sendAction 'select', code
