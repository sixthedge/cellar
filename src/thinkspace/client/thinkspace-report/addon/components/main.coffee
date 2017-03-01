import ember from 'ember'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import base  from 'thinkspace-base/components/base'

export default base.extend

  tvo_titles: 'thinkspace-report'

  drop_id: ember.computed -> "ts-drop_#{@get('elementId')}"

  reports: null

  init_base: ->
    @first_button = @get('report_dropdown').shift()
    @get_reports().then => @set_all_data_loaded()

  actions:
    generate: (member) ->
      @dd and @dd.close()
      query =
        verb:     'post'
        action:   'generate'
        model:    ns.to_p('report:report')
        authable: @get('model')
      @totem_scope.add_auth_to_ajax_query(query)
      query.data.type = member.report_type
      @totem_messages.show_loading_outlet(message: 'Requesting reports...')
      ajax.object(query).then =>
        @totem_messages.hide_loading_outlet()

  didInsertElement: ->
    $ul = @$('ul')
    return if ember.isBlank($ul)
    @dd = new Foundation.Dropdown($ul)

  get_reports: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @tc.find_all(ns.to_p('report:report')).then (reports) =>
        @set 'reports', reports
        resolve()
