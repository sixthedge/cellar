import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'
import m_menu from 'thinkspace-readiness-assurance-instructor/mixins/menu'

export default base.extend m_menu,

  menu: ember.computed.reads 'am.trat_summary_menu'
