import ember       from 'ember'
import base        from 'thinkspace-readiness-assurance-instructor/components/base'
import m_data_rows from 'thinkspace-readiness-assurance/mixins/data_rows'
import ns          from 'totem/ns'

export default base.extend m_data_rows,
  # # Computed properties
  progress_report: ember.computed.reads 'am.data_values.progress_report'

  # # Events
  init_base: -> 
    @am.get_trat_assessment().then (assessment) =>
      @set('assessment', assessment)
      @set_ready_on()