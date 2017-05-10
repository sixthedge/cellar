import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'totem-table/components/table/cell'

export default base.extend
  # # Computed properties
  has_space_user: ember.computed.notEmpty 'space_user'
  state:          ember.computed.reads    'space_user.friendly_state'

  init_base: ->
    @set_space_user().then =>
      @set_all_data_loaded()

  set_space_user: ->
    new ember.RSVP.Promise (resolve, reject) =>
      user     = @get('row')
      space    = @get_column_data('space')
      space_id = parseInt(space.get('id'))
      user.get(ns.to_p('space_users')).then (space_users) =>
        space_user = space_users.findBy('space_id', space_id)
        @set('space_user', space_user)
        resolve()