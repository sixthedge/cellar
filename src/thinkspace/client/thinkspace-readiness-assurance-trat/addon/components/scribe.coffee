import ember from 'ember'
import util  from 'totem/util'
import base  from 'thinkspace-base/components/base'

export default base.extend

  is_scribe:  ember.computed      'rm.scribe_user_id', -> @get('rm.scribe_user_id') == @rm.current_user_id()
  has_scribe: ember.computed.bool 'rm.scribe_user_id'

  actions:
    add:    -> @rm.save_status('scribe')
    remove: -> @rm.save_status('unscribe')
