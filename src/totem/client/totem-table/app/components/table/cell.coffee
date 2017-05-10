import ember from 'ember'
import cell  from 'totem-table/components/table/cell'

export default cell.extend
  init_base: -> @init_value()
  
  init_value: ->
    col  = @get('column')
    row  = @get('row')
    prop = col.property
    @set('value', row.get(prop))
    