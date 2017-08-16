import ember           from 'ember'
import totem_changeset from 'totem/changeset'
import base            from 'thinkspace-base/components/base'
import vcomparison     from 'thinkspace-builder-pe/validators/comparison'


export default base.extend
  # # Services
  ttz: ember.inject.service()

  # # Properties
  changeset: null

  # # Computed properties
  is_irat: ember.computed.equal 'type', 'irat'
  is_trat: ember.computed.equal 'type', 'trat'

  no_errors:  ember.computed.empty 'changeset.errors'
  has_errors: ember.computed.not 'no_errors'

  date_errors: ember.computed 'changeset.errors', ->
    errors = @get('changeset.errors')
    if ember.isPresent(errors.findBy('key', 'unlock_at'))
      return errors.findBy('key', 'unlock_at').validation
    else if ember.isPresent(errors.findBy('key', 'due_at'))
      return errors.findBy('key', 'due_at').validation

  # # Events
  init_base: -> 
    @set_changeset()
    @register_changeset()
  
  # # Helpers
  register_changeset: ->
    step      = @get('step')
    changeset = @get('changeset')
    step.register_phase_changeset(@get('type'), changeset)

  set_changeset: ->
    model     = @get('model')
    vpresence = totem_changeset.vpresence(true)

    changeset = totem_changeset.create model,
      due_at:    [vcomparison({compare_to: 'unlock_at', type: 'gt', message: 'Release date must be set before the due date'})],
      unlock_at: [vcomparison({compare_to: 'due_at',    type: 'lt', message: 'Release date must be set before the due date',})]
    changeset.set('configuration', null) # No configuration changes are made here.
    @set('changeset', changeset)

  # ## Date setters
  set_date: (type, date) -> 
    changeset = @get('changeset')
    if type == 'unlock_at'
      changeset.set(type, date)
      changeset.set('due_at', changeset.get('due_at'))
    else
      changeset.set(type, date)
      changeset.set('unlock_at', changeset.get('unlock_at'))

  actions:
    select_unlock_at: (date) -> @set_date('unlock_at', date)
    select_due_at: (date) ->    @set_date('due_at', date)
