import ember from 'ember'
import base  from 'thinkspace-base/components/base'
import m_text_support from 'totem/mixins/changeset/text_support'

export default base.extend m_text_support,
  # classNames: ['ts-validated-input', 'ts-validated-checkbox']
  classNames: ['checkbox__item']
  default_attributes: {}
  default_actions:    {}

  is_checked: ember.computed 'value', -> @get_value() == 'true'

  checkbox_value: ember.computed
    get: (key)        -> @get('is_checked')
    set: (key, value) ->
      val = if value == true then 'true' else 'false'
      @set('value', val)
      @send_action('save', val)
      value == true
