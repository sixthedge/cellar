import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend

  model: null ## Assignment

  is_archived: ember.computed.equal 'model.state', 'archived'
  is_draft:    ember.computed.equal 'model.state', 'inactive'
  is_active:   ember.computed.equal 'model.state', 'active'
  is_released: ember.computed.reads 'model.is_released'

  is_editing_release_date: false

  set_is_editing_release_date: ->   @set('is_editing_release_date', true)
  reset_is_editing_release_date: -> @set('is_editing_release_date', false)

  save_release_date: (date) ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get('model')
      model.set('release_at', date)
      model.save().then => resolve()

  init_base: ->
    @set_loading 'link'
    model = @get('model')
    model.get('assignment_type').then (assignment_type) =>
      if assignment_type.get('is_pe')
        settings = 'pe_settings'
      else
        settings = 'rat_settings'
      @set 'settings', settings
      @reset_loading 'link'

  actions:

    edit_release_at: -> @set_is_editing_release_date()

    set_drafting: ->
      model = @get('model')
      model.inactivate()
      @set('state', 'testing')

    set_active: ->
      model = @get('model')
      model.activate()
      @set('state', 'test')

    set_archived: ->
      model = @get('model')
      model.archive()
      @set('state', 'archived')

    select_release_at: (date) -> @save_release_date(date)
