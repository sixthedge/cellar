import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName: 'li'

  is_selected:     ember.computed 'model', 'selected', -> @get('model') == @get('selected')
  is_current_team: ember.computed 'model', 'selected', -> @get('model') == @get('current_team')

  actions:
    select: -> @sendAction 'select', @get('model')
