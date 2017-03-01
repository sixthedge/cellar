import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend

  tvo_titles: 'readiness-assurance-irat'

  init_base: ->
    @rm.init_manager
      assessment: @get('model')
      readonly:   @get('viewonly')
      irat:       true
