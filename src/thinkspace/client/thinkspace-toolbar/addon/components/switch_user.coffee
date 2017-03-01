import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName: ''

  actions:
    switch_user: ->
      console.warn 'switch user'
      return

      space = @current_models().get_current_space()
      @totem_messages.invalidate_session()  if ember.isBlank(space)
      data    = {space_id: space.get('id')}
      session = @get('session')
      session.authenticate('authenticator_switch_user:totem', session, data).then =>
        @totem_messages.show_loading_outlet()
        window.location = window.location.pathname  # remove the query string (e.g. phase's query_id) and reload the page
        # window.location.reload()
        # window.location.reload(true)  # do not use browser cache
        return
      , (error) =>
        console.error "Cannot switch user. Error:", error
