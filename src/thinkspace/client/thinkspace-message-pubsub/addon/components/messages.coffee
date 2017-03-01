import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName: ''

  server_events: ember.inject.service()

  init_base: ->
    @se           = @get('server_events')
    @messages     = @se.messages
    @filter_rooms = @se.get_filter_rooms()
    @filters      = []
    @messages.get_new_messages_filter(@filter_rooms).then      (filter) => @filters.push(filter); @set 'filtered_new_messages', filter
    @messages.get_previous_messages_filter(@filter_rooms).then (filter) => @filters.push(filter); @set 'filtered_previous_messages', filter

  sort_by:           ['date:desc']
  new_messages:      ember.computed.sort 'filtered_new_messages', 'sort_by'
  previous_messages: ember.computed.sort 'filtered_previous_messages', 'sort_by'

  has_new_messages:      ember.computed.notEmpty 'new_messages'
  has_previous_messages: ember.computed.notEmpty 'previous_messages'
  has_messages:          ember.computed.or 'has_new_messages', 'has_previous_messages'

  show_new:      false
  show_previous: false

  actions:
    mark_previous: (msg) ->
      msg.set_previous()
      @set_show_new()

    mark_all_previous: ->
      @messages.move_all_new_to_previous(@filter_rooms)
      @set_show_new()

    mark_all_previous_inactive: -> @messages.move_all_to_inactive('is_previous', @filter_rooms)

    toggle_new:      -> @toggleProperty('show_new'); return
    toggle_previous: -> @toggleProperty('show_previous'); return

  willDestroy: -> filter.destroy() for filter in @filters

  set_show_new: ->
    ember.run.next => @set('show_new', false) if ember.isBlank(@get('new_messages'))
