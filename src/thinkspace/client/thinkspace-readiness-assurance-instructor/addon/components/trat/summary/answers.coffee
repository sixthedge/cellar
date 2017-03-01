import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'
import m_data_rows from 'thinkspace-readiness-assurance/mixins/data_rows'

export default base.extend m_data_rows,

  columns_per_row: 5
  qms_rows:        null
  assessment:      null

  willInsertElement: -> @setup()

  setup: ->
    @am.get_trat_assessment().then (assessment) =>
      @set 'assessment', assessment
      @am.get_trat_response_managers().then (rms) =>
        qids  = assessment.get_question_ids()
        array = []
        for qid in qids
          qms = (rm.question_manager_map.get(qid) for rm in rms)
          array.push(qms)
        @set 'qms_rows', @get_data_rows(array)
        @set_ready_on()
