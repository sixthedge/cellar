import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

###
# # overview/states.coffee
- Type: **Component**
- Package: **thinkspace-peer-assessment**
###
export default base.extend
  # ## Properties
  # ### Internal Properties
  model: null ## Assignment
  is_editing_release_date: false

  # ### Computed Properties
  is_archived: ember.computed.equal 'model.state', 'archived'
  is_draft:    ember.computed.equal 'model.state', 'inactive'
  is_active:   ember.computed.equal 'model.state', 'active'


  # ## Helpers
  set_is_editing_release_date: ->   @set('is_editing_release_date', true)
  reset_is_editing_release_date: -> @set('is_editing_release_date', false)

  # ## Actions
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
