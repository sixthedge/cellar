import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend

  tvo_titles: 'readiness-assurance-trat'

  init_base: ->
    console.warn '====TRAT', @

  # TODO: Is this okay moving it from init_base?  @totem_data is not setup in init_base.
  willInsertElement: ->
    @totem_data.ability.refresh().then =>
      @rm.init_manager
        assessment:            @get('model')
        readonly:              @get('viewonly')
        can_update_assessment: @can.update
        trat:                  true
        room_users_header:     'Team Members'

  willDestroy: -> @rm.leave_room()

  chat_ids: []

  actions:
    chat: (qid) ->
      @get('chat_ids').pushObject(qid)

    chat_close: (qid) ->
      chat_ids = @get('chat_ids')
      if ember.isBlank(qid)
        chat_ids.clear()
      else
        @set 'chat_ids', chat_ids.without(qid)
