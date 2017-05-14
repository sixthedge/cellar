import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # details.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend
  builder: ember.inject.service()

  model: ember.computed.reads 'builder.model'
  step:  ember.computed.reads 'builder.step_details'

  init_base: ->
    @get('step').validate().then =>
      @set('changeset', @get('step.changeset'))

  has_title_error: ember.computed 'changeset', ->
    errors = @get('changeset.errors')
    return false unless ember.isPresent(errors)
    if ember.isPresent(errors.findBy('key', 'title'))
      return !ember.isEmpty(errors.findBy('key', 'title').validation)

  has_instruction_error: ember.computed 'changeset', ->
    errors = @get('changeset.errors')
    return false unless ember.isPresent(errors)
    if ember.isPresent(errors.findBy('key', 'instructions'))
      return !ember.isEmpty(errors.findBy('key', 'instructions').validation)