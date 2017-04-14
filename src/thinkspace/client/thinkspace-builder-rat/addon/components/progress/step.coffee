import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # step.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend
  tagName: 'li'
  classNames: ['builder-progress__item']
  classNameBindings: ['is_current_step:builder-progress__item--is-currrent']

  builder: ember.inject.service()

  steps: ember.computed.reads 'builder.steps'
  model: ember.computed.reads 'builder.model'

  is_current_step: ember.computed 'builder.current_step', 'step', ->  @get('builder.current_step') == @get('step')

  actions:

    transition: ->
      step    = @get('step')
      builder = @get('builder')
      builder.transition_to_step(step, save: true)