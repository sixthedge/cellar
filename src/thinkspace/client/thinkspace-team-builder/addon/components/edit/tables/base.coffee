import ember          from 'ember'
import base_component from 'thinkspace-base/components/base'
import column         from 'thinkspace-common/table/column'
import selectable_mixin from 'thinkspace-common/mixins/table/cells/selectable'

## Component to handle rendering and actions for the edit component's assigned users
export default base_component.extend selectable_mixin,

  has_selected: ember.computed.notEmpty 'selected_rows'
  students:     null

  select_row: (opts) -> 
    @_super(opts)
    @sendAction('select', opts)

  reset_selected_rows: -> @set('selected_rows', ember.makeArray())
