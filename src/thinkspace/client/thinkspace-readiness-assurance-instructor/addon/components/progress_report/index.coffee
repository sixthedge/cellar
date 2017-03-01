import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'

export default base.extend
  init_base: ->
    @am.set_model @get('model')