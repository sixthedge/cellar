import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName: 'li'

  current_user:    ember.computed.reads 'totem_scope.current_user'
  is_current_user: ember.computed 'model', 'current_user', -> @get('model') == @get('current_user')
  is_selected:     ember.computed 'model', 'selected',     -> @get('model') == @get('selected')

  actions:
    select: -> @sendAction 'select', @get('model')
