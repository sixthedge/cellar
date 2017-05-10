import ember from 'ember'
import base  from 'thinkspace-base/components/base'
import ns    from 'totem/ns'

export default base.extend
  tagName:           'li'
  classNames:        ['dropdown__item', 'dropdown__item--thick', 'dropdown__item-selectable']
  classNameBindings: ['is_selected:is-selected']
  
  is_selected: ember.computed 'selected_users.@each', -> 
    return false if ember.isEmpty(@get('selected_users'))
    @get('selected_users').contains(@get('model'))

  full_name: ember.computed 'model.first_name', 'model.last_name', -> "#{@get('model.first_name')} #{@get('model.last_name')}"

  click: -> @sendAction 'select', @get('model')
