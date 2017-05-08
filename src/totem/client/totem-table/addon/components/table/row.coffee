import ember from 'ember'
import opt   from 'totem-table/table/options'
import base  from 'totem-table/components/table/base'

export default base.extend
  # # Properties
  tagName: 'tr'

  # ## Component properties
  c_table: null

  # ## Data properties
  row:     null
  columns: null

  is_selected: false
  
  select: (options) ->
    @toggleProperty('is_selected')
    row_opts = opt.create
      components:
        cell: options.get_component('cell')
        row:  @
    @get('c_table').select_row(row_opts)