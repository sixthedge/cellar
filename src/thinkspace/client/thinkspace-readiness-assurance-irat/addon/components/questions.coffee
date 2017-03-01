import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend

  question_managers: ember.computed ->
    managers = []
    @rm.question_manager_map.forEach (qm) => managers.push(qm)
    managers
