import ember from 'ember'
import ajax  from 'totem/ajax'

export default ember.Mixin.create

  send_timer_cancel: (timer) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve() if ember.isBlank(timer)
      platform     = @get_platform()
      url          = "#{platform}/pub_sub/server_events/timer_cancel"
      verb         = 'post'
      id           = timer.id
      room         = timer.room
      room_event   = timer.room_event
      user_id      = timer.user_id
      end_at       = timer.end_date
      timer_cancel = {id, room, room_event, user_id, end_at}
      data         = {timer_cancel}
      query        = {url, verb, data}
      ajax.object(query).then =>
        resolve()
      , (error) =>
        reject(error)
