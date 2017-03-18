import ember            from 'ember'
import base             from 'thinkspace-common/components/table/table'
import pagination_array from 'totem-application/pagination/arrays/client'

export default base.extend
  # # Clicks
  # ## Events
  click_cell:   (options) -> console.log('[table/client] cell clicked')
  click_header: (options) ->
    console.log('[table/client] header clicked')
    header = @get_component_from_click_options(options, 'header')
    @col_click(header.get('column'))

  # # Helpers
  # ## Getters/setters
  # Note: This needs to be overriden here because it needs to create a paginated array.
  set_rows: (rows) ->
    array = pagination_array.create
      all_content: rows
    @set('rows', array)

  # ## Sorting
  update_col_direction: (col) ->
    columns    = @get('columns')
    config_col = columns.findBy 'order', col.order

    # TODO: Should this always just flip?
    if config_col.selected
      @flip_direction(config_col)
    else
      @set_col_direction(col, 'asc')

  set_col_direction: (column, direction) ->
    return unless (direction == 'asc' || direction == 'desc')
    column.direction = direction

  flip_direction: (col) ->
    if col.direction == 'asc'
      col.direction = 'desc'
    else
      col.direction = 'asc'

  sort_records_by_property: (col, records) ->
    return unless ember.isPresent(col.property)
    sorted_records = records.sortBy(col.property)
    sorted_records = sorted_records.reverse() if col.direction == 'desc'
    @set_rows(sorted_records)

  get_rows_all_content: -> @get('rows.all_content')

  col_click: (col) ->
    @update_col_direction(col)
    @update_col_selected(col)
    @sort_records_by_property(col, @get_rows_all_content())

