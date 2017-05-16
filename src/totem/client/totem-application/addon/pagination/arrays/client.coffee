import ember from 'ember'
import ajax  from 'totem/ajax'
import tc    from 'totem/cache'
import range from 'totem-application/mixins/pagination/arrays/range'

export default ember.ArrayProxy.extend range,
  # # Properties
  all_content:  null # Array of all models that have been loaded, used in the 'show more' usage instead of discrete pages.
  is_paginated: true
  is_loading:   false

  per_page:     null
  total_pages:  null 
  current_page: null 

  # # Computed properties
  total_records: ember.computed.reads 'all_content.length'
  
  has_next_page: ember.computed 'current_page', 'total_pages', ->
    current_page = @get_current_page()
    total_pages  = @get_total_pages()
    current_page < total_pages

  has_prev_page: ember.computed 'current_page', ->
    current_page = @get_current_page()
    (current_page - 1) > 0

  has_pages: ember.computed.gt 'total_pages', 1

  range: ember.computed 'per_page', 'total_records', 'total_pages', 'current_page', ->
    per_page      = @get('per_page')
    total_pages   = @get('total_pages')
    total_records = @get('total_records')
    current_page  = @get('current_page')
    min      = if current_page > 1 then (per_page*(current_page-1) + 1) else 1
    if current_page == total_pages
      if total_records <= (current_page * per_page)
        max = total_records
      else
        max = (current_page * per_page)
    else
        max = (current_page * per_page)
    "Showing #{min} to #{max} of #{total_records} items"

  # # Events
  init: ->
    all_content  = @get('all_content')  || []
    current_page = @get('current_page') || 1
    per_page     = @get('per_page')     || 10

    @set_all_content(all_content)
    @set_pagination(current_page, per_page)
    @set_content()

  # # Pagination promises
  get_first_page: (options={}) -> @get_page_for('first')
  get_last_page:  (options={}) -> @get_page_for('last')
  get_next_page:  (options={}) -> @get_page_for('next')
  get_prev_page:  (options={}) -> @get_page_for('prev')

  get_page_for: (page) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @set_is_loading()
      switch page
        when 'first'
          @set_current_page(1)
        when 'last'
          @set_current_page(@get_total_pages())
        when 'next'
          @set_current_page_from_offset(1)
        when 'prev'
          @set_current_page_from_offset(-1)
      @set_content()
      @reset_is_loading()
      resolve()

  # # Getter/setter helpers
  get_content:      -> @get('content')
  get_current_page: -> @get('current_page')
  get_total_pages:  -> @get('total_pages')
  get_all_content:  -> @get('all_content')
  get_per_page:     -> @get('per_page')
  set_is_loading:   -> @set('is_loading', true)
  reset_is_loading: -> @set('is_loading', false)
  
  set_pagination: (current_page, per_page) ->
    @set_current_page(current_page)
    @set_per_page(per_page)
    @set_total_pages()

  set_current_page: (page)     -> @set('current_page', page)
  set_per_page:     (per_page) -> @set('per_page', per_page)
  set_total_pages: ->
    length      = @get('all_content.length')
    per_page    = @get_per_page() || 1
    total_pages = Math.ceil(length / per_page)
    @set('total_pages', total_pages)

  set_all_content: (content)   -> @set('all_content', ember.makeArray(content))

  set_current_page_from_offset: (offset) ->
    current_page = @get_current_page()
    total_pages  = @get_total_pages()
    new_page     = current_page + offset
    new_page     = 1 if new_page <= 0
    new_page     = total_pages if new_page > total_pages
    @set('current_page', new_page)

  set_content: ->
    all_content  = @get_all_content()
    [start, end] = @slice_options()
    content      = all_content.slice(start, end)
    @set('content', content)

  # # Misc. helpers
  slice_options: ->
    current_page = @get_current_page() || 0
    per_page     = @get_per_page() || 0
    start_index  = ((current_page - 1) * per_page)
    end_index    = per_page * current_page
    [start_index, end_index]
