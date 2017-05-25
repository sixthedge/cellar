import ember from 'ember'
import cell  from 'totem-table/components/table/cell'
import opt   from 'totem-table/table/options'

export default cell.extend

  render_component: ember.computed.reads 'column.data.calling'

  click: (event) ->
    options = opt.create
      components:
        cell:  @
        row:   @get('c_row')
        table: @get('c_table')
      data:
        row:    @get('row')
        column: @get('column')

    console.log('delete click event is ', event)

    component = @get('column.data.calling')

    component.delete_row(options)
    
  # actions:
  #   click: ->
  #     options = opt.create
  #       components:
  #         cell: @
  #         row:  @get('c_row')
  #       data:
  #         row:    @get('row')
  #         column: @get('column')

  #     console.log('delete click')

  #     @get('data.calling').delete_row(options)