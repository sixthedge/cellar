import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'
import m_to_trat from 'thinkspace-readiness-assurance-instructor/mixins/to_trat'

export default base.extend m_to_trat,

  init_to_trat: ->
    @irad.set 'transition_now', true

  validate_data: ->
    @irad.clear_errors()
    @trad.clear_errors()
    @trad.error 'You have not selected any teams.' if ember.isBlank @trad.get_teams()
