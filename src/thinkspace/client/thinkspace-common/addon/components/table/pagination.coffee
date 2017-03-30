import ember from 'ember'
import base  from 'thinkspace-common/components/table/base'

export default base.extend
  # # Properties
  rows:    null
  
  # ## Component properties
  c_table: null

  actions:
    next:  -> @get_table().get_next_page()
    prev:  -> @get_table().get_prev_page()
    first: -> @get_table().get_first_page()
    last:  -> @get_table().get_last_page()