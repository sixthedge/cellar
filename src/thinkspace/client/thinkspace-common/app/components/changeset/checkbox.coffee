import ember          from 'ember'
import base           from 'thinkspace-base/components/base'
import m_text_support from 'totem/mixins/changeset/text_support'

export default base.extend m_text_support,
  # # Properties
  classNames: ['checkbox__item']

  # # Events
  click: (event) ->  @send_action('save')