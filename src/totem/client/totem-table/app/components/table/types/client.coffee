import ember            from 'ember'
import base             from 'totem-table/components/table/table'
import pagination_array from 'totem-application/pagination/arrays/client'

export default base.extend
  # # Properties
  table_type: 'client'

  # # Clicks
  # ## Events
  click_cell:   (options) -> console.log('[table/client] cell clicked')
  click_header: (options) ->
    column = options.get_data('column')
    console.log('[table/client] header clicked', column)
    @handle_header_click(column)

  # ### Helpers
  handle_header_click: (column) ->
    @set_loading('rows')
    @reset_column_directions(column)
    column.invert_direction()
    @set_column_selected(column)
    @set_sorted_rows(column)
    @reset_loading('rows')

  set_column_selected: (column) ->
    columns = @get('columns')
    columns.forEach (c) => c.reset_selected()
    column.set_selected()

  set_sorted_rows: (column) ->
    property = column.get_property()
    return unless property
    rows   = @get_rows_all_content()
    sorted = rows.sortBy(property)
    sorted = sorted.reverse() if column.get('is_descending')
    @set_rows(sorted)

  delete_row: (row) ->
    @sendAction('delete_row', row)

  # # Helpers
  # ## Getters/setters
  # Note: This needs to be overriden here because it needs to create a paginated array.
  set_rows: (rows) ->
    array = pagination_array.create
      all_content: rows
    @set('rows', array)

  get_rows_all_content: -> 
    @get('rows.all_content')