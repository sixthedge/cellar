import ember            from 'ember'
import base             from 'totem-table/components/table/table'
import pagination_array from 'totem-application/pagination/arrays/client'

export default base.extend
  # # Properties
  table_type: 'server'

  # # Clicks
  # ## Events
  click_cell:   (options) -> console.log("[table/server] cell clicked")
  click_header: (options) ->
    console.log("[table/server] header clicked", options)
    source = @get_data('source')
    fn     = @get_data('sort')
    column = options.get_data('column')
    @set_loading('rows')
    @reset_column_directions(column)
    source[fn](column).then (rows) =>
      @reset_loading('rows')
      @set_rows(rows)
    , (error) =>
      @reset_loading('rows')

  # # Helpers
  # ## Getters/setters
  # Note: This needs to be overriden here because it is already a paginated array.
  set_rows: (rows) ->
    @set('rows', rows)

