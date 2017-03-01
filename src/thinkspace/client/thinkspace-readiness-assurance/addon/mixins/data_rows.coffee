import ember from 'ember'

export default ember.Mixin.create

  # Split an array of data object into rows based on the 'columns_per_row
  # e.g. builds an array-of-arrays (each array containing the rows data).

  columns_per_row: 2    # override in component to use a different value
  column_width:    300  # override in component to use a different value (integer => number of pixels)

  columns_class: null # add in template e.g. .ts-grid_columns.ts-grid_columns-thick class=columns_class

  get_data_rows: (data) ->
    cpr      = @get_column_per_row()
    row_data = ember.makeArray(data)
    @set_columns_class(row_data)
    rows  = []
    len   = row_data.length
    nrows = Math.ceil(len / cpr)
    for row in  [0..(nrows - 1)]
      row_array = []
      r         = row * cpr
      for i in [0..(cpr - 1)]
        index = r + i
        row_array.push(row_data[index])  unless index >= len
      rows.push(row_array)
    rows

  set_columns_class: (data) ->
    cpr    = @get_column_per_row()
    dlen   = data.length
    div_by = if dlen < cpr then dlen else cpr
    col    = Math.floor(12 / div_by)
    @set 'columns_class', "small-#{col}"

  get_column_per_row: ->
    cpr = @get('columns_per_row')
    if typeof(cpr) == 'string' then @auto_columns_per_row(cpr) else cpr

  auto_columns_per_row: (cpr) ->
    dcpr     = 1 # default columns-per-row
    $element = $(cpr).first()
    element  = $element[0]
    return dcpr if ember.isBlank(element)
    wclient = element.clientWidth
    return dcpr if ember.isBlank(wclient) or wclient <= 0
    wcol = @get('column_width')
    return dcpr if ember.isBlank(wcol) or wcol <= 0
    return dcpr if wcol >= wclient
    ncols = Math.floor(wclient / wcol)
    if ncols > 0 then ncols else 1
