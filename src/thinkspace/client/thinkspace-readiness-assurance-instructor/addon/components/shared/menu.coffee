import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'

export default base.extend

  select: 'select'
  done:   'done'
  clear:  'clear'

  actions:
    clear:           -> @sendAction 'clear'
    select: (config) -> @sendAction 'select', config
    done:   (config) -> @sendAction 'done', config
