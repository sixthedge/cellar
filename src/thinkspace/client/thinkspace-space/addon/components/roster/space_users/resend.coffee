import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'totem-table/components/table/cell'

export default base.extend
  # # Properties
  space_user: null 

  # # Computed properties
  space:       ember.computed.reads 'column.data.space'
  is_inactive: ember.computed.reads 'row.is_inactive'

  # # Events
  init_base: ->
    @set_loading('space_user')
    @init_space_user().then =>
      @reset_loading('space_user')

  init_space_user: ->
    new ember.RSVP.Promise (resolve, reject) =>
      space = @get('space')
      user  = @get('row')
      return resolve() unless space and user
      store = @get_store()
      user.get(ns.to_p('space_users')).then (sus) =>
        record = sus.findBy('space_id', parseInt(space.get('id')))
        @set('space_user', record)
        resolve()

  # # Helpers
  get_store: -> @totem_scope.get_store()

  send_query: ->
    space_user = @get('space_user')
    user       = @get('row')
    return unless space_user
    options = 
      action: 'resend'
      verb:   'PUT'
    query =
      id: space_user.get('id')
    @tc.query_data(ns.to_p('space_user'), query, options).then =>
      @totem_messages.info "Invitation resent to #{user.get('email')}"

  actions:
    resend: -> @send_query()
