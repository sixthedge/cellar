import ember from 'ember'
import base  from 'thinkspace-common/components/table/base'

export default base.extend
  # # Properties
  tagName:       ''
  rows:          null
  columns:       null
  selected_rows: null

  rows_obs: ember.observer 'rows', 'rows.length', ->
    console.log('[TABLE] rows are ', @get('rows'))

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

  select_row: (options) ->
    selected_rows = @get('selected_rows')
    selected_rows = ember.makeArray() unless ember.isPresent(selected_rows)
    row = options.get_component('row')
    if selected_rows.contains(row) then selected_rows.removeObject(row) else selected_rows.pushObject(row)
    @set('selected_rows', selected_rows)

  get_selected_rows: -> @get('selected_rows')

  delete_row: (options) ->
    console.log('calling delete with @', @, @get('delete_row'))
    @sendAction('delete_row', options)
