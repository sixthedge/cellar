import ember from 'ember'
import ajax  from 'totem/ajax'
import tc    from 'totem/cache'

export default ember.ArrayProxy.extend
  # ### Properties
  links:        null # JSON API format links, see: http://jsonapi.org/format/#fetching-pagination
  meta:         null # JSON API format meta, see: http://jsonapi.org/extensions/
  type:         null # Model to use for pushing to the store.
  all_content:  null # Array of all models that have been loaded, used in the 'show more' usage instead of discrete pages.
  is_paginated: true
  is_loading:   false

  has_next_page: ember.computed.notEmpty 'links.next'
  has_prev_page: ember.computed.notEmpty 'links.prev'
  total_pages:   ember.computed.reads 'meta.page.total'
  current_page:  ember.computed.reads 'meta.page.current'

  # ### Events
  init: ->
    @set 'all_content', []

  # ### Pagination promises
  get_first_page: (options={}) -> @get_page_for_link('first', false, options)
  get_last_page:  (options={}) -> @get_page_for_link('last',  false, options)
  get_next_page:  (options={}) -> @get_page_for_link('next',  false, options)
  get_prev_page:  (options={}) -> @get_page_for_link('prev',  false, options)

  get_page_for_link: (link, is_url=true, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      unless is_url
        link = @get_pagination_link(link)
      switch
        when ember.isPresent(link)
          @set_is_loading()
          params  = options.params || {}
          options = 
            url:  link
            data: params
          ajax.object(options).then (payload) => 
            @process_pagination_payload(payload)
            @reset_is_loading()
            resolve(@)
          , (error) => console.error "[pagination:array] Error in resolving the next page for type [#{type}].", @
        else
          #@set_content([])
          resolve(@)
    , (error) => console.error "[pagination:array] Error in `get_page_for_link`: ", @

  # ### Getter/setter helpers
  get_pagination_link: (link) -> @get("links.#{link}")
  set_content_type:    (type) -> @set 'type', type
  get_content_type:    -> @get 'type'
  get_content:         -> @get 'content'
  get_all_content:     -> @get 'all_content'
  set_content:         (content) ->
    @add_to_all_content(content)
    @set 'content', content
  add_to_all_content: (content) ->
    # TODO: Better way to do this?  Push and flatten?
    all_content = @get 'all_content'
    content.forEach (record) => 
      all_content.pushObject(record) unless all_content.includes(record)

  set_is_loading:   -> @set 'is_loading', true
  reset_is_loading: -> @set 'is_loading', false

  # ### Payload processing
  process_pagination_payload: (payload, type=null) ->
    @set_content_type(type) if ember.isPresent(type)
    @set_pagination_links_from_payload(payload)
    @set_pagination_meta_from_payload(payload)
    @set_content_from_payload(payload)

  set_pagination_meta_from_payload: (payload) ->
    @set 'meta', payload.meta
    delete payload.meta

  set_pagination_links_from_payload: (payload) ->
    @set 'links', payload.links
    delete payload.links

  set_content_from_payload: (payload) ->
    type    = @get_content_type()
    records = tc.push_payload_and_return_records_for_type(payload, type)
    @set_content records