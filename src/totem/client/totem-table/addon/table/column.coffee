import ember from 'ember'

export default ember.Object.extend
  # # Properties
  selected:  null # TODO: Need?
  direction: null # Initial direction set by component that defines the columns.  Assumes it is presorted to this.

  # ## Cell component properties
  component: null # Component path, if specified, will render instead of the basic cell component.
  data:      null # Data object to be passed to the component if specified.

  # ## Header properties
  display:   null # What to display in the <th> tag.
  property:  null # What property to get on the row to display.

  # # Computed properties
  has_property:  ember.computed.notEmpty 'property'
  is_descending: ember.computed 'direction', -> @get_direction() == 'DESC'
  is_ascending:  ember.computed 'direction',  -> @get_direction() == 'ASC'

  # # Helpers
  # ## Property helpers
  get_property: -> @get('property')

  # ## Direction helpers
  get_direction: -> (@get('direction') || '').toUpperCase()
  set_direction: (direction) -> @set('direction', direction)
  invert_direction: ->
    # TODO: How should the null case be handled?
    direction = @get_direction()
    if ember.isEmpty(direction) or @get('is_descending')
      direction = 'ASC'
    else
      direction = 'DESC'
    @set_direction(direction)
    direction

  # ## Selected helpers
  set_selected:   -> @set('selected', true)
  reset_selected: -> @set('selected', false)

