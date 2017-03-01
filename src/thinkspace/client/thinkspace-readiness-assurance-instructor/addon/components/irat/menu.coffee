import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'
import m_menu from 'thinkspace-readiness-assurance-instructor/mixins/menu'

export default base.extend m_menu,

  menu: ember.computed.reads 'am.irat_menu'

  # ### TESTING ONLY - auto-select
  # init_menu: ->
    # @select_action @find_config(@am.c_messages_view)
    # @select_action @find_config(@am.c_menu_irat_to_trat)
    # @select_action @find_config(@am.c_irat_phase_states)
  # ### TESTING ONLY
