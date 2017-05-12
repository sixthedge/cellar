import ember from 'ember'
import base  from 'totem-base/components/base'

export default base.extend
  # # Properties
  tagName: 'input'
  type:    'radio'

  classNames: ['radio__input']

  attributeBindings: [
    'id',
    'checked',
    'disabled',
    'name',
    'required',
    'type',
    'value'
  ]
  