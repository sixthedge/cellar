import ember from 'ember'

export default ember.Mixin.create

  get_mock_phase_state: (ownerable, phase) ->
    @mock_phase_state_object.create
      ember:          ember
      ns:             @ns
      is_mock:        true
      id:             'mock'
      title:          'mock-phase-state'
      mock_phase:     phase
      mock_ownerable: ownerable
      ownerable_type: @totem_scope.record_model_name(ownerable)
      ownerable_id:   ownerable.get('id')

  mock_phase_state_object: ember.Object.extend
    init: ->
      @_super(arguments...)
      @ember.defineProperty @, 'ownerable',       @ember.computed -> @get_record('mock_ownerable')
      @ember.defineProperty @, @ns.to_p('phase'), @ember.computed -> @get_record('mock_phase')
    get_record: (prop) -> new ember.RSVP.Promise (resolve, reject) => resolve @get(prop)
