import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'
import m_menu from 'thinkspace-readiness-assurance-instructor/mixins/menu'

export default base.extend m_menu,

  menu: ember.computed.reads 'am.irat_to_trat_menu'

  # ### TESTING ONLY - auto-select
  didInsertElement: ->
    # @select_action @find_config(@am.c_irat_to_trat_due_at)
    # @select_action @find_config(@am.c_irat_to_trat_after)
  # ### TESTING ONLY
