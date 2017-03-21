import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

###
# # review_set.coffee
- Type: **Component**
- Package: **thinkspace-peer-assessment-instructor**
###
export default base_component.extend
  # ## Events
  init_base: ->
    model = @get('model')
    split = model.name.split(' ')
    initials = split[0].charAt(0).capitalize() + split[split.length - 1].charAt(0).capitalize()
    ember.set model, 'html_title', model.name
    ember.set model, 'initials', initials

  # ## Actions
  actions:
    select: -> @sendAction 'select', @get('model')
