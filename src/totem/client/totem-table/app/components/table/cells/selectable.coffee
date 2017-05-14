import ember from 'ember'
import cell  from 'totem-table/components/table/cell'
import opt   from 'totem-table/table/options'

export default cell.extend

  is_selected: ember.computed 'column.data.calling.component.selected_rows.@each', ->
    selected_rows = @get('column.data.calling.component.selected_rows')
    row = @get('c_row.row')
    return false if ember.isEmpty(selected_rows)
    selected_rows.contains(row)

  click: ->
    options = opt.create
      components:
        cell: @
        row: @get('c_row')
        table: @get('c_table')
      data:
        row: @get('row')
        column: @get('column')

    component = @get('column.data.calling.component')
    if ember.isPresent(component)
      component.select_row(options)

  register_table_component: ->
    component = @get('column.data.calling.component')
    component.register_table(@get('c_table')) if ember.isPresent(component)

  init_base: ->
    if @get('column.data.calling.register')
      @register_table_component()
