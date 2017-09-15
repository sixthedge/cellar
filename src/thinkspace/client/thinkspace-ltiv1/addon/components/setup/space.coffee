import ember           from 'ember'
import base            from 'thinkspace-base/components/base'

export default base.extend
  tagName: 'li'
  classNameBindings: ['is_selected:is-selected']

  is_selected: ember.computed 'selected_space', -> @get('selected_space') == @get('model')

  click: -> @send 'select'

  actions:

    select: ->
      @sendAction 'select', @get('model')