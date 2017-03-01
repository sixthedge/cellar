import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'

export default base.extend

  message_title: ember.computed -> @title or 'Message'

  actions:
    clear:   -> @rad.clear_message()
    default: -> @rad.add_default_message()
