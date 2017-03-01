import ember from 'ember'
import base  from 'thinkspace-base/components/base'
import m_text_support from 'totem/mixins/changeset/text_support'

export default base.extend m_text_support,
  classNames: ['ts-validated-input', 'ts-validated-radio']

  default_attributes: {}
  default_actions:    {}

  is_selected: ember.computed 'changeset.change', -> @get_value() == @get_radio_value()

  actions:
    select: ->
      value = @get_radio_value()
      @set('value', value)
      @send_action('save', value)

  get_radio_value: -> @get('radio_value')
