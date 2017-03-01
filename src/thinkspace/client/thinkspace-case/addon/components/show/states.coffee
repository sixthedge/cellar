import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend

  model: null ## Assignment

  is_archived: ember.computed.equal 'model.state', 'archived'
  is_draft:    ember.computed.equal 'model.state', 'inactive'
  is_active:   ember.computed.equal 'model.state', 'active'

  is_editing_release_date: false

  set_is_editing_release_date: ->   @set('is_editing_release_date', true)
  reset_is_editing_release_date: -> @set('is_editing_release_date', false)

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
