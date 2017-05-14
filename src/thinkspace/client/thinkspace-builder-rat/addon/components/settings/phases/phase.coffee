import ember           from 'ember'
import totem_changeset from 'totem/changeset'
import base            from 'thinkspace-base/components/base'

export default base.extend
  # # Services
  ttz: ember.inject.service()

  # # Properties
  changeset: null

  # # Computed properties
  is_irat: ember.computed.equal 'type', 'irat'
  is_trat: ember.computed.equal 'type', 'trat'

  # # Events
  init_base: -> @set_changeset()

  # # Saving
  save: ->
    changeset = @get('changeset')
    changeset.validate().then => 
      if changeset.get('is_valid')
        changeset.save()

  # # Helpers
  set_changeset: ->
    model = @get('model')
    changeset = totem_changeset.create(model)
    changeset.set('configuration', null) # No configuration changes are made here.
    @set('changeset', changeset)

  # ## Date setters
  set_date: (type, date) -> @get('changeset').set(type, date)
  set_assignment_date: (type, date) ->
    step = @get('step')
    step.set("changeset.#{type}", date)
    step.save()

  actions:
    select_unlock_at: (date) ->
      console.log "DATE IS: ", date
      @set_date('unlock_at', date)
      @set_assignment_date('release_at', date) if @get('is_irat')
      @sendAction('select_unlock_at', date) # TODO: These don't seem to be hooked up?
      @save()

    select_due_at: (date) -> 
      @set_date('due_at', date)
      @set_assignment_date('due_at', date) if @get('is_trat')
      @sendAction('select_due_at', date) # TODO: These don't seem to be hooked up?
      @save()