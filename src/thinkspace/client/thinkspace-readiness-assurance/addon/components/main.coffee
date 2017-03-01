import ember from 'ember'
import base  from 'thinkspace-base/components/base'
import response_manager from 'thinkspace-readiness-assurance/managers/response'

export default base.extend

  tvo_titles: 'readiness-assurance'

  ttz:           ember.inject.service()
  server_events: ember.inject.service()

  is_irat: ember.computed.reads 'model.is_irat'
  is_trat: ember.computed.reads 'model.is_trat'

  init_base: ->
    @se = @get('server_events')
    @se.set_filter_rooms @se.assignment_current_user_room()
    tvo         = @get('tvo')
    hash        = tvo.template.dup_value(@tvo_path)
    hash.title  = @get_ra_title()
    hash.values = @get_ra_values()
    @ra_path    = tvo.value.set_value(hash)
    @se.load_messages()
    @set_all_data_loaded()

  get_ra_title: ->
    switch
      when @get('is_irat')  then title = 'irat'
      when @get('is_trat')  then title = 'trat'
      else title = ''
    "readiness-assurance-#{title}"

  get_ra_values: ->
    hash    = {}
    hash.rm = @get_response_manager()
    hash

  get_response_manager: ->
    response_manager.create
      store:  @get('store')
      tvo:    @get('tvo')
      ttz:    @get('ttz')
      se:     @se
      pubsub: @se.pubsub

  # # ### TESTING ONLY
  # test_init: ->
  #   @messages = @get('server_events.messages')
  #   @add_test_message("test message 1 ", 'aaaa')
  #   @add_test_message("test message 2 ", 'bbbb')
  #   @add_test_message("test message 3 ", 'cccc')
  # add_test_message: (msg, room=null) -> @messages.add(message: "#{new Date().toString()} - #{msg}", room: room)
  # # ### TESTING ONLY
