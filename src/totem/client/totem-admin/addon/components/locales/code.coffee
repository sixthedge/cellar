import ember from 'ember'
import base  from 'totem-base/components/base'

export default base.extend
  tagName: ''

  active: ember.computed 'active_code', -> @active_code == @code

  actions:
    select: (code) -> @sendAction 'select', code
