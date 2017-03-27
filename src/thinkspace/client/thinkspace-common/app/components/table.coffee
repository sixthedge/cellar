import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend

  rows:    null
  columns: null

  defaults: {
    direction: 'asc'
    selected:  false
  }

  init_base: ->
    @init_column_defaults()

  init_column_defaults: ->
    defaults = @get('defaults')
    columns  = @get('columns')

    for i in [0..columns.get('length')-1]
      column = columns[i]

      for key, value of defaults
        column["#{key}"] = value unless ember.isPresent(column["#{key}"])

      column['order'] = i

  update_col_selected: (col) ->
    columns = @get('columns')
    columns.forEach (column) =>
      column['selected'] = false
      if column.order == col.order
        column['selected'] = true

    console.log('config_col now ', columns)
    columns

  update_col_direction: (col) ->
    columns    = @get('columns')
    config_col = columns.findBy 'order', col.order

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
    @set('rows', sorted_records)

  col_click: (col) ->
    @update_col_direction(col)
    @update_col_selected(col)
    @sort_records_by_property(col, @get('rows'))

  actions:
    header_click: (header) ->
      console.log('clicked header ', header, header.get('column'))

      @col_click(header.get('column'))