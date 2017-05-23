import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'

export default base.extend  
  # # Properties
  tagName:   'li'
  model:     null # {ownerable_type: 'Thinkspace::Team::Team', ownerable_id: 1}
  ownerable: null # Resolved ownerable

  # # Computed properties
  justification: ember.computed.reads 'model.justification'

  # # Events
  init_base: ->
    @set_ownerable()

  # # Setters
  set_ownerable: ->
    @get_ownerable().then (ownerable) =>
      @set('ownerable', ownerable)
      @set_ready_on()

  get_ownerable: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model        = @get('model')
      return resolve(null) unless model
      ownerable_id   = model.ownerable_id
      ownerable_type = model.ownerable_type
      return resolve(null) unless ownerable_id and ownerable_type
      ownerable_type = @totem_scope.standard_record_path(ownerable_type)
      @tc.find_record(ownerable_type, ownerable_id).then (ownerable) =>
        resolve(ownerable)
      , (error) => reject(error)
    , (error) => reject(error)