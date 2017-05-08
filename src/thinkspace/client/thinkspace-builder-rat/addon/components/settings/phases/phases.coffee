import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName: 'ul'

  init: ->
    @_super()
    console.log('model set to ', @get('model'))
    @set_all_data_loaded()

  bulk_reset_date: (property) ->
    @reset_all_data_loaded()
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get('model')
      ids   = model.getEach('id')

      options =
        property: property
        ids:      ids

      query =
        action:   'bulk_reset_date'
        verb:     'POST'

      @tc.query_action(ns.to_p('phase'), options, query).then (phases) =>
        @set_all_data_loaded()
        resolve phases

      # @tc.query(ns.to_p('phase'), query).then (phases) =>
      #   @set_all_data_loaded()
      #   resolve phases

  actions: 

    select_unlock_at: (date) -> @sendAction 'select_unlock_at', date

    register_phase: (component) ->
      @sendAction 'register_phase', component

    reset_unlock_at: -> @bulk_reset_date('unlock_at')
    reset_due_at:    -> @bulk_reset_date('due_at')
