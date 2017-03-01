import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'
import m_data_rows from 'thinkspace-readiness-assurance/mixins/data_rows'

export default base.extend m_data_rows,

  columns_per_row: 1
  qms_rows:        null

  willInsertElement: -> @setup()

  setup: ->
    @am.get_trat_assessment().then (assessment) =>
      @am.get_trat_response_managers().then (rms) =>
        qids = assessment.get_question_ids()
        qms  = []
        for qid in qids
          array = []
          for rm in rms
            qm = rm.question_manager_map.get(qid)
            array.push(qm)
          qms.push(array)
        @set 'qms_rows', @get_data_rows(qms)
        @set_ready_on()

