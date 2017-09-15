import ember           from 'ember'
import base            from 'thinkspace-base/components/base'

export default base.extend
  tagName: 'li'
  classNameBindings: ['is-selected:is_selected']

  is_selected: ember.computed 'selected_assignment', -> @get('selected_assignment') == @get('model')

  click: -> @send 'select'

  actions:

    select: ->
      @sendAction 'select', @get('model')