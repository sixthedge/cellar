import ember from 'ember'

## Performs default functionality for components implementing 'thinkspace-common/components/table/cells/selectable' in a table.

export default ember.Mixin.create

  selected_rows: null
  ## Selectable cell passes a thinkspace-common/addon/table/options object, which handles
  ## the passing of table data
  select_row: (opts) -> 
    row           = opts.get_data('row')
    selected_rows = @get('selected_rows') || ember.makeArray()
    if selected_rows.contains(row)
      selected_rows.removeObject(row)
    else
      selected_rows.pushObject(row)
    @set('selected_rows', selected_rows)