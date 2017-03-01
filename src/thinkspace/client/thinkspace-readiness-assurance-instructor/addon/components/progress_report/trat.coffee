import ember       from 'ember'
import base        from 'thinkspace-readiness-assurance-instructor/components/base'
import m_data_rows from 'thinkspace-readiness-assurance/mixins/data_rows'

export default base.extend m_data_rows,
  # ### Services
  thinkspace: ember.inject.service()

  # ### Properties
  qms_rows:        null
  assessment:      null
  
  progress_report: ember.computed.reads 'am.data_values.progress_report'
  is_ifat:         ember.computed.reads 'assessment.is_ifat'

  init_base: -> 
    @am.set_model @get('model')

  willInsertElement: -> @setup()

  setup: ->
    @am.get_trat_assessment().then (assessment) =>
      @set('assessment', assessment)
      @am.set_trat_progress_report().then =>
        @am.join_rat_progress_report_room()
        @set_ready_on() # TODO: Refactor this to not rely on data_rows mixin.