import ember       from 'ember'
import base        from 'thinkspace-readiness-assurance-instructor/components/base'
import m_data_rows from 'thinkspace-readiness-assurance/mixins/data_rows'
import ns          from 'totem/ns'

export default base.extend m_data_rows,
  # # Computed properties
  is_ifat: ember.computed.reads 'assessment.is_ifat'

  # # Events
  init_base: -> 
    @am.get_trat_assessment().then (assessment) =>
      @set('assessment', assessment)
      @set_ready_on()