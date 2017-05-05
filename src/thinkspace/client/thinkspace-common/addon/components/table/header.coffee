import ember from 'ember'
import base  from 'thinkspace-common/components/table/base'
import opt   from 'thinkspace-common/table/options'

export default base.extend
  # # Properties
  tagName: 'th'
  classNameBindings: ['direction_class', 'sortable_class']

  # ## Component properties
  c_table: null
  
  # ## Data properties
  column:  null

  # # Computed properties
  value:     ember.computed.reads 'column.display'
  direction: ember.computed.reads 'column.direction'
  property:  ember.computed.reads 'column.property'

  # ## Class helpers
  # Bound to the header to add icons for sort capabilities/direction.
  direction_class: ember.computed 'direction', ->
    direction = @get('direction')
    if direction then "th-sort__#{direction.toLowerCase()}" else null

  sortable_class: ember.computed 'property', -> if @get('property') then 'th-sortable' else null

  # # Event handlers
  click: ->
    options = opt.create
      components:
        header: @
      data:
        column: @get('column')
    @get_table().click_header(options)

