import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'

export default base.extend
  overview: ember.computed.reads 'am.data_values.progress_report_overview'
  
  init_base: ->
    @am.set_model @get('model')
    @am.set_progress_report_overview().then =>
      @set_ready_on()
