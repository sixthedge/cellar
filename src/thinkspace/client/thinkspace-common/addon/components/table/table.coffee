import ember from 'ember'
import base  from 'thinkspace-common/components/table/base'

export default base.extend
  # # Properties
  tagName: ''
  rows:    null
  columns: null

  # ## Action handlers
  handle_click_header: 'handle_click_header'
  handle_click_cell:   'handle_click_cell'

  # # Clicks
  # ## Events
  click_cell:   (options) -> @warn('click_cell')
  click_header: (options) -> @warn('click_header')

  # # Pagination
  # ## Helpers
  get_next_page:  -> @get_rows().get_next_page()
  get_prev_page:  -> @get_rows().get_prev_page()
  get_first_page: -> @get_rows().get_first_page()
  get_last_page:  -> @get_rows().get_last_page()

  # # Helpers
  # ## Getters/setters
  get_rows: -> @get('rows')
  set_rows: -> @warn('set_rows')

  # ## Logging
  warn: (fn) -> console.warn("[table/table] #{fn} needs to be implemented in the table type: #{@get('table_type')}.")

  # # Events
  init_base: ->
    @init_rows().then =>
      @set_all_data_loaded()
      @_super()

  init_rows: ->
    new ember.RSVP.Promise (resolve, reject) =>
      rows = @get('rows')
      @set_rows(rows)
      resolve()