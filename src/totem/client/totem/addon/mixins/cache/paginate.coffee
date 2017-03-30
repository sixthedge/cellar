import ember            from 'ember'
import pagination_array from 'totem-application/pagination/arrays/server'

export default ember.Mixin.create

  add_pagination_to_query: (query, number, size=15) ->
    query.page = @get_pagination_options(number, size)
    query

  get_default_pagination_query: ->
    query      = {}
    query.page = @get_pagination_options(1)
    query

  get_pagination_options: (number, size=15) ->
    {number: number, size: size}

  get_paginated_array: (type, payload) ->
    array = pagination_array.create()
    array.process_pagination_payload(payload, type)
    array
