import ember from 'ember'

export default ember.Mixin.create

  current_user:    null
  current_user_id: null
  no_current_user: ember.computed.none  'current_user'

  # Convience fucntions to identify if the current user has been set.
  current_user_blank:   -> @get('no_current_user')
  current_user_present: -> not @current_user_blank()

  get_current_user: ->
    @set_current_user()  if @current_user_blank()
    @get('current_user')

  get_current_user_id: ->
    @set_current_user()  if @current_user_blank()
    @get('current_user_id')

  set_current_user: (user) ->
    if user then id = parseInt(user.get('id')) else id = null
    @set 'current_user', user
    @set 'current_user_id', id

  get_current_user_path: -> @get_record_path @get_current_user()
  get_current_user_type: -> @get_current_user_path()
