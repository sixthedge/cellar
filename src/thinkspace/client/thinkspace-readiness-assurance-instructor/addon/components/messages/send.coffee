import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'

export default base.extend

  show_select: true

  init_base: ->
    @rad = @am.rad(name: 'MSG', width_selector: '.ts-ra_admin-message-content')

  willInsertElement: ->
    @am.get_trat_team_users().then (team_users) =>
      @team_users = team_users
      @rad.set_team_users(team_users)
      # @rad.select_all_users_on()
      @rad.show_all_on()
      @set_ready_on()

  actions:
    done:          -> @sendAction 'done', @config
    toggle_select: -> @toggleProperty('show_select'); return
    validate:      -> @validate()

    send_message: ->
      @selected_send_on()
      @validate()
      return if ember.isPresent(@rad.errors)
      message = @rad.get_data()
      @am.send_message_to_users({message})

  validate: ->
    @rad.clear_errors()
    @rad.error "You must enter a message."        if ember.isBlank(@rad.get_message())
    @rad.error "You have not selected any users." if ember.isBlank(@rad.get_users())
