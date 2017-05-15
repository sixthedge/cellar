import ember from 'ember'
import ns    from 'totem/ns'

export default ember.Mixin.create

  ##### Assumes that whatever we're being mixed into has a table_config

  update_col_selected: (col) ->
    table_config = @get('table_config')
    table_config.forEach (table_col) =>
      table_col['selected'] = false
      if table_col.id == col.id
        table_col['selected'] = true
    table_config

  update_col_direction: (col) ->
    table_config = @get('table_config')
    config_col   = table_config.findBy 'id', col.id

    @flip_direction(config_col) if config_col.selected

  flip_direction: (col) ->
    if col.direction == 'asc'
      col.direction = 'desc'
    else
      col.direction = 'asc'

  sort_records_by_attribute: (col, records) ->
    return unless ember.isPresent(col.attribute)
    sorted_records = records.sortBy(col.attribute)
    sorted_records = sorted_records.reverse() if col.direction == 'desc'
    @update_sorted(sorted_records)

  col_click: (col, records) ->
    @update_col_direction(col)
    @update_col_selected(col)
    if ember.isPresent(col.action)
      @send(col.action, col)
    else
      @sort_records_by_attribute(col, records)
