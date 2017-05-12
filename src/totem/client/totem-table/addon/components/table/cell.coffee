import ember from 'ember'
import opt   from 'totem-table/table/options'
import base  from 'totem-table/components/table/base'

export default base.extend
  # # Properties
  tagName: 'td'

  # ## Component properties
  c_table: null
  c_row:   null

  # ## Data properties
  row:     null
  column:  null

  # # Event handlers
  click: ->
    options = opt.create
      components:
        cell: @
        row:  @get('c_row')
      data:
        row:    @get('row')
        column: @get('column')
    @get_table().click_cell(options)