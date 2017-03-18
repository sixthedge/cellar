import ember            from 'ember'
import base             from 'thinkspace-common/components/table/table'
import pagination_array from 'totem-application/pagination/arrays/client'

export default base.extend
  # # Clicks
  # ## Events
  click_cell:   (options) -> console.log("[table/server] cell clicked");
  click_header: (options) -> console.log("[table/server] header clicked");

  # # Helpers
  # ## Getters/setters
  # Note: This needs to be overriden here because it is already a paginated array.
  set_rows: (rows) -> @set('rows', rows)

