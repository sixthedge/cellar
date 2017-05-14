import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  # # Properties
  model: null ## Assignment

  # # Computed properties
  date:  ember.computed.reads 'model.release_at'

  # # Events
  didInsertElement: ->
    modal = new Foundation.Reveal($('#change-date'))
    @set('modal', modal)

  # # Helpers
  persist_release_date: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get('model')
      date  = @get('date')
      model.set('release_at', date)
      model.save().then => resolve()

  actions:
    select_release_at: (date) -> @set('date', date)

    confirm: ->
      @persist_release_date().then =>
        @get('modal').close()
      
    deny: ->
      @send 'close'
      @sendAction 'deny'

    close: -> @get('modal').close()
