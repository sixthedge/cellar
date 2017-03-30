import ember from 'ember'
import base  from 'thinkspace-common/components/table/base'

export default base.extend
  # # Properties
  tagName: 'tr'

  # ## Component properties
  c_table: null

  # ## Data properties
  row:     null
  columns: null
  