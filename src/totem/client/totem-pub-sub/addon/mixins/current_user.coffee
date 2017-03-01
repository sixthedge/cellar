import ember from 'ember'

export default ember.Mixin.create

  is_current_user_id: (id) -> id and id == @current_user_id()

  current_user_id: -> @get_totem_scope().get_current_user_id()

  current_user: -> @get_totem_scope().get_current_user()

  current_user_email: ->
    user = @current_user()
    return null unless user
    user.get('email')

  current_user_full_name: ->
    user = @current_user()
    return 'unknown' unless user
    user.get('full_name')
