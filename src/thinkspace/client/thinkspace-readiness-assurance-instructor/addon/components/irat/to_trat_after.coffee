import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'
import m_to_trat from 'thinkspace-readiness-assurance-instructor/mixins/to_trat'

export default base.extend m_to_trat,

  # TODO: Reset due_at on send_transition incase delayed pressing transition button?

  init_to_trat: -> @trad.select_all_teams_on()

  button_range: [
    {start: 1,  end: 5,  by: 1}
    {start: 10, end: 30, by: 5}
  ]
