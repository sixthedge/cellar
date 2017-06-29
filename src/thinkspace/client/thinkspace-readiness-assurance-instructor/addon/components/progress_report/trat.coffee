import ember       from 'ember'
import base        from 'thinkspace-readiness-assurance-instructor/components/base'
import m_data_rows from 'thinkspace-readiness-assurance/mixins/data_rows'
import ns          from 'totem/ns'

export default base.extend m_data_rows,
  # # Properties
  assessment: null
  
  # # Computed properties
  progress_report: ember.computed.reads 'am.data_values.progress_report'

  no_of_concerns: ember.computed 'progress_report.concerns.length', -> @get('progress_report.concerns.length') || 0

  # # Events
  init_base: -> 
    @am.set_model @get('model')

  willInsertElement: -> @setup()

  # # Helpers
  setup: ->
    @am.get_trat_assessment().then (assessment) =>
      @set('assessment', assessment)
      @am.set_trat_progress_report().then =>
        @am.join_rat_progress_report_room()
        @set_ready_on()