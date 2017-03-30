import ember from 'ember'
import cell  from 'thinkspace-common/components/table/cell'
import opt   from 'thinkspace-common/table/options'

export default cell.extend

  is_selected: false

  click: ->
    options = opt.create
      components:
        cell: @
        row: @get('c_row')
        table: @get('c_table')
      data:
        row: @get('row')
        column: @get('column')

    component = @get('column.data.calling')
    if ember.isPresent(component)
      component.select_row(options)
      @toggleProperty('is_selected')