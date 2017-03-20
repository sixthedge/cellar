import ember from 'ember'
import base  from 'thinkspace-common/components/table/base'
import opt   from 'thinkspace-common/table/options'

export default base.extend
  # # Properties
  tagName: 'th'

  # ## Component properties
  c_table: null
  
  # ## Data properties
  column:  null

  # # Computed properties
  value: ember.computed.reads 'column.display'

  # # Event handlers
  click: ->
    options = opt.create
      components:
        header: @
      data:
        column: @get('column')
    @get_table().click_header(options)

