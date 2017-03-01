import ember       from 'ember'
import ns          from 'totem/ns'
import ajax        from 'totem/ajax'

export default ember.Mixin.create
  set_trat_progress_report: ->
    new ember.RSVP.Promise (resolve, reject) =>
      url = @get_trat_url('progress_report')
      @set_progress_report(url).then (payload) =>
        resolve(payload)

  set_irat_progress_report: ->
    new ember.RSVP.Promise (resolve, reject) =>
      url = @get_irat_url('progress_report')
      @set_progress_report(url).then (payload) =>
        resolve(payload)

  set_progress_report: (url) ->
    new ember.RSVP.Promise (resolve, reject) =>
      query = @get_auth_query(url)
      ajax.object(query).then (payload) =>
        @set_data_value('progress_report', payload)
        resolve(payload)

  join_rat_progress_report_room: ->
    options = 
      room:       @se.get_admin_room()
      source:     @
      callback:   'handle_progress_report'
      room_event: 'progress_report'
    @se.pubsub.join(options)

  handle_progress_report: (data) ->
    progress_report = data.value
    console.log "[am:progress_reports] handle_progress_report: ", progress_report
    @set_data_value('progress_report', progress_report)

  get_progress_report_data_for_question_id: (id) ->
    pr     = @get_data_value('progress_report')
    result = pr.results.findBy('id', id)
    console.log "[am:progress_reports] Question for [#{id}]: ", result
    result
