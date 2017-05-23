import ember       from 'ember'
import base        from 'thinkspace-readiness-assurance-instructor/components/base'
import m_data_rows from 'thinkspace-readiness-assurance/mixins/data_rows'
import ns          from 'totem/ns'
import column      from 'totem-table/table/column'

export default base.extend
  # # Properties
  team_rows: null

  # # Computed properties
  progress_report: ember.computed.reads 'am.data_values.progress_report'
  team_users:      ember.computed.reads 'am.data_values.trat_team_users'

  # ## Table
  team_columns: ember.computed 'assessment', 'rms', ->
    assessment = @get('assessment')
    qs         = assessment.get('question_settings')
    return [] if ember.isEmpty(qs)
    columns = [
      column.create({display: 'Team',  property: 'title', direction: 'ASC'})
    ]
    qs.forEach (q, index) =>
      display = (index + 1)
      id      = q.id
      c       = column.create({display: display, property: 'null', sortable: false, component: 'progress_report/trat/chat/cell', data: {question_id: id, rms: @get('rms')}})
      columns.pushObject(c)
    columns

  team_data: ember.computed -> { source: @ }

  # # Events
  willInsertElement: -> @setup()

  setup: ->
    @am.get_trat_assessment().then (assessment) =>
      @set('assessment', assessment)
      @am.get_trat_response_managers().then (rms) =>
        rows = []
        @get('team_users').forEach (team_user) =>
          row = ember.Object.create
            title: team_user.team.title
            id:    team_user.team.id
          rows.pushObject(row)
        @set('team_rows', rows)
        @set('rms', rms)
        @set_ready_on()
