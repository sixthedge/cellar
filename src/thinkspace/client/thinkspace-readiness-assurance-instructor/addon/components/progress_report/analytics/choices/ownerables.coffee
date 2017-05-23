import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'

export default base.extend  
  # # Properties
  tagName:   ''
  model:     null # Choice
  
  # # Computed properties
  ownerables_sorting: ['full_name']
  sorted_ownerables: ember.computed.sort 'ownerables', 'ownerables_sorting'

  # # Events
  init_base: ->
    @set_ownerables()

  set_ownerables: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @get_ownerables().then (ownerables) =>
        @set('ownerables', ownerables)
        resolve()
      , (error) => reject(error)
    , (error) => reject(error)

  get_ownerables: ->
    new ember.RSVP.Promise (resolve, reject) =>
      ownerables = @get('model.ownerables')
      return resolve([]) unless ownerables
      promises   = []
      ownerables.forEach (ownerable) => promises.pushObject(@get_ownerable(ownerable))
      ember.RSVP.all(promises).then (results) =>
        results.forEach (result) =>
          full_name           = result.get('full_name')
          ownerable           = ownerables.findBy('ownerable_id', parseInt(result.get('id')))
          ownerable.full_name = full_name if ownerable
        resolve(ownerables)

  get_ownerable: (ownerable) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve(null) unless ownerable
      ownerable_id   = ownerable.ownerable_id
      ownerable_type = ownerable.ownerable_type
      return resolve(null) unless ownerable_id and ownerable_type
      ownerable_type = @totem_scope.standard_record_path(ownerable_type)
      @tc.find_record(ownerable_type, ownerable_id).then (ownerable) =>
        resolve(ownerable)
      , (error) => reject(error)
    , (error) => reject(error)
    