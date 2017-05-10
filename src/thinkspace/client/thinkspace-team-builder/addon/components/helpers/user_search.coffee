import ember from 'ember'
import base  from 'thinkspace-base/components/base'
import ns    from 'totem/ns'

export default base.extend
  
  value:          null
  space:          null
  results:        null
  search_results: null
  select:         null

  search_watcher: ember.observer 'value', ->
    value = @get('value')

    if ember.isEmpty(value)
      @set_results(null)
    else
      ember.run.debounce(@, @search, 250)

  set_results: (val) ->
    # @set('results', val)
    @sendAction('search_results', val)

  search: -> @send('search')

  actions:
    search: ->
      value = @get('value')

      params =
        id:   @get('space.id')
        type: 'roster'
        terms: value

      options =
        action: 'search'
        model: ns.to_p('user')

      @tc.query_action(ns.to_p('space'), params, options).then (users) =>
        @set_results(users)

    select: (user) -> @sendAction('select', user)