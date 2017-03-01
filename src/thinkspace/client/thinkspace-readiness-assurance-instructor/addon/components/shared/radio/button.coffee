import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'

export default base.extend

  button_id:    ember.computed.reads 'button.id'
  button_label: ember.computed.reads 'button.label'

  label_select: ember.computed -> @label_selectable != false

  is_selected: ember.computed 'selected_id', -> @selected_id == @get('button_id')

  actions:
    select: -> @sendAction 'select', @get('button_id')

