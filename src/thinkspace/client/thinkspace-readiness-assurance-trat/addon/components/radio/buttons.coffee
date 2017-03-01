import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName:           'div'
  classNameBindings: ['no_errors::ts-ra_error']

  actions:
    select: (id) -> @sendAction 'select', id
