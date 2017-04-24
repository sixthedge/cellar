import ember      from 'ember'
import util       from 'totem/util'
import base  from 'thinkspace-base/components/base'

export default base.extend
  # Properties
  model:             null
  selected_user:     null
  clickable:         false
  size:              'small'
  tagName:           ''

  is_small:             ember.computed.equal 'size', 'small'
  is_medium:            ember.computed.equal 'size', 'medium'
  is_large:             ember.computed.equal 'size', 'large'
  is_selected:          ember.computed 'selected_user', -> ember.isEqual(@get('model'), @get('selected_user'))

  css_style: ember.computed 'model', ->
    color = @get 'model.color'
    return '' unless ember.isPresent(color)
    css = ''
    css += "background-color: ##{color};"
    css.htmlSafe()

  actions:
    select_user: -> @sendAction 'select_user', @get('model')