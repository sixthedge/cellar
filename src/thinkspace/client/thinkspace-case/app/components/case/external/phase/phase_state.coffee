import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  # # Properties
  tagName:           'div'
  model:             null # PhaseState
  phase:             null # Phase
  classNames:        ['tag', 'tag--pill', 'spacing__margin-right--1']
  classNameBindings: [
    'model.is_locked:tag__exercise-status--locked',
    'model.is_unlocked:tag--blue',
    'model.is_completed:tag--green',
    'model.is_past_due:tag--red'
  ]

  # # Computed properties
  # TODO: Probably a better way to do this.
  text: ember.computed 'model', ->
    model = @get('model')
    switch
      when model.get('is_past_due')
        'Past Due'
      when model.get('is_completed')
        'Completed'
      when model.get('is_locked')
        'Locked'
      when model.get('is_unlocked')
        'Unlocked'
      when model.get('is_view_only')
        'Read Only'