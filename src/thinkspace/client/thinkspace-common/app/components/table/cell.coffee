import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName: ''

  init_base: ->
    console.log('[CELL] col, row, ', @get('column'), @get('row.first_name'))
    @init_value()
  
  init_value: ->
    col = @get('column')
    row = @get('row')

    prop = col.property
    @set('value', row.get(prop))

  # value: ember.computed 'column.@each', ->
  #   property = @get('column.property')
  #   row      = @get('row')
  #   row.get('property')

  actions:
    click: -> @sendAction('click', @)