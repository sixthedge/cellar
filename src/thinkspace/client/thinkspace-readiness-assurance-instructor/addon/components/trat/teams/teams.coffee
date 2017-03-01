import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'
import m_data_rows from 'thinkspace-readiness-assurance/mixins/data_rows'

export default base.extend m_data_rows,

  show_team_members: false
  columns_per_row:   5
  team_member_rows:  null

  actions:
    toggle_team_members: -> @toggleProperty 'show_team_members'; return

  init_base: ->
    @am.get_trat_team_users().then (teams) =>
      @set 'team_member_rows', @get_data_rows(teams)
      @set_ready_on()
