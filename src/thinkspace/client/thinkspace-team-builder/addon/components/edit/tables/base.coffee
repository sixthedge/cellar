import ember            from 'ember'
import column           from 'totem-table/table/column'
import base_component   from 'thinkspace-base/components/base'
import selectable_mixin from 'thinkspace-common/mixins/table/cells/selectable'

## Component to handle rendering and actions for the edit component's assigned users
export default base_component.extend selectable_mixin,

  has_selected: ember.computed.notEmpty 'selected_rows'
  students:     null

  select_row: (opts) -> 
    @_super(opts)
    @sendAction('select', opts)

  reset_selected_rows: -> @set('selected_rows', ember.makeArray())

  ## Imperfect way to allow the rendering component to cause a table to re-render via init_rows
  register_table: (table) -> 
    @sendAction('register', table)