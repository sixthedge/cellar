import ember from 'ember'
import base  from 'totem-base/components/base'

export default base.extend
  # # Helpers
  get_table:       -> @get('c_table')
  get_data:        (property) -> @get("data.#{property}")
  get_column_data: (property) -> @get("column.data.#{property}")