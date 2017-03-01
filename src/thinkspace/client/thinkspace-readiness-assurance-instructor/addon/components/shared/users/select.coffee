import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'
import m_data_rows from 'thinkspace-readiness-assurance/mixins/data_rows'

export default base.extend m_data_rows,

  show_all:         false
  user_member_rows: null
  columns_per_row:  ember.computed -> (ember.isPresent(@rad.width_selector) and @rad.width_selector) or 1

  init_base: -> @validate = @rad.validate

  willInsertElement: -> @setup()

  setup: ->
    @all_users = @rad.get_all_users()
    @users     = @rad.get_users() or []
    @set 'show_all', @rad.get_show_all()
    @send 'select_all' if @rad.select_all_users()
    @set 'user_member_rows', @get_data_rows(@am.sort_users(@all_users))

  actions:
    show_all:   -> @set 'show_all', true
    hide_all:   -> @set 'show_all', false

    select_all:   ->
      @users.clear()
      @users.pushObject(user) for user in @all_users
      @set_users()

    deselect_all: ->
      @users.clear()
      @set_users()

    select: (user) ->
      index = @users.indexOf(user)
      if index >= 0
        @users.removeAt(index)
      else
        @users.pushObject(user)
      @set_users()

  set_users: ->
    @rad.set_users(@users)
    @sendAction 'validate' if @validate
