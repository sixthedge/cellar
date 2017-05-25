import ember from 'ember'
import cell  from 'totem-table/components/table/cell'

export default cell.extend
  init_base: -> @init_value()
  
  init_value: ->
    col  = @get('column')
    row  = @get('row')
    prop = col.property
    if row.get? then value = row.get(prop) else value = row[prop]
    @set('value', value)
    