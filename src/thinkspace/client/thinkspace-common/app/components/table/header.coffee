import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName: ''

  value: ember.computed.reads 'column.display'

  actions:
    click: ->
      @sendAction('click', @)