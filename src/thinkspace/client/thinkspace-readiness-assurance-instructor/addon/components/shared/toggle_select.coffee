import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'

export default base.extend

  actions:
    toggle: -> @toggleProperty('rad.show_select'); return
