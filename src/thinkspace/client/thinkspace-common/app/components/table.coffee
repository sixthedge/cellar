import ember            from 'ember'
import base             from 'thinkspace-base/components/base'

export default base.extend
  # # Properties
  tagName: ''
  rows:    null  # Array of <row> stubs, or ember-data models.
  columns: null  # Array of Column objects.
  data:    null  # Object containing callback information for sorts, etc.
  server:  false # Render the table/types/server versus table/types/client.

  # ## Action handlers
  # Note: These are part of the base table component, but only these are needed.
  # => To avoid having to override `init_base`, etc, these are copied into here.
  handle_click_header: 'handle_click_header'
  handle_click_cell:   'handle_click_cell'