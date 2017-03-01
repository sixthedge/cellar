import ember from 'ember'
import ta from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.belongs_to 'element', reads: {name: 'input_element'}
  ),

  value:          ta.attr('string')
  ownerable_id:   ta.attr('number')
  ownerable_type: ta.attr('string')

  # This is a fix for an issue regarding totem_scope and carry_forward.
  # => If you load in a certain order, it causes an issue with the element's response_ids getting reset.
  # => To replicate (with this observer commented out):
  #     => 1) Go to a phase without carry forward or the inputs themselves.
  #     => 2) Go to a phase with the carry forward only.
  #     => 3) Go to a phase with the inputs themselves.
  # => At this point, it makes a request to /contents/:id then to contents/:id/view_users
  # => The initial call to /contents/:id is for current_user's data and resets the element's response_ids.
  # => Some of the records from view_users have already been loaded (does NOT retrigger didLoad), causing them to never be pushed back onto the parent.
  # response_change: ember.observer "#{ta.to_p('element')}.#{ta.to_p('responses')}", ->  @didLoad()

  # didCreate: -> @didLoad()
  #
  # didLoad: ->
  #   @get(ta.to_p 'element').then (element) =>
  #     if element
  #       element.get(ta.to_p 'responses').then (responses) =>
  #         responses.pushObject(@) if responses and not responses.includes(@)
