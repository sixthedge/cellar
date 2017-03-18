import ember from 'ember'
import base  from 'thinkspace-common/components/table/base'

export default base.extend
  # # Properties
  tagName: ''
  rows:    null
  columns: null

  # ## Default properties
  defaults:
    direction: 'asc'
    selected:  false

  # # Clicks
  # ## Events
  click_cell:   (options) -> @warn('click_cell')
  click_header: (options) -> @warn('click_header')

  # # Pagination
  # ## Helpers
  get_next_page:  -> @get_rows().get_next_page()
  get_prev_page:  -> @get_rows().get_prev_page()
  get_first_page: -> @get_rows().get_first_page()
  get_last_page:  -> @get_rows().get_last_page()

  # # Helpers
  # ## Getters/setters
  get_rows: -> @get('rows')
  set_rows: -> @warn('set_rows')

  get_component_from_click_options: (options, property) -> options.components[property]
  get_data_from_click_options:      (options, property) -> options.data[property]

  # ## Logging
  warn: (fn) -> console.warn("[table/table] #{fn} needs to be implemented in the table type.")






  # TODO: REFACTOR EVERYTHING BELOW THIS
  # => Everything should be a Promise just to ensure it is async-safe.
  init_base: ->
    @init_rows()
    @init_column_defaults()
    @_super()

  init_rows: ->
    rows = @get('rows')
    @set_rows(rows)

  init_column_defaults: ->
    defaults = @get('defaults')
    columns  = @get('columns')
    for i in [0..columns.get('length')-1]
      column = columns[i]
      for key, value of defaults
        column["#{key}"] = value unless ember.isPresent(column["#{key}"])
      column['order'] = i

  # # Column helpers
  update_col_selected: (col) ->
    columns = @get('columns')
    columns.forEach (column) =>
      column['selected'] = false
      if column.order == col.order
        column['selected'] = true
    console.log('config_col now ', columns)
    columns
