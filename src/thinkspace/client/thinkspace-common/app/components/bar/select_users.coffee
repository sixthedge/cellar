import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName: ''

  current_user:    ember.computed.reads 'totem_scope.current_user'
  is_current_user: ember.computed 'selected', 'current_user', -> @get('selected') == @get('current_user')

  show_dropdown: false
  selected:      null

  dropdown_users:  null
  prev_next_users: null

  default_setup_options:
    include_current_user_in_dropdown:      true
    include_current_user_in_previous_next: false

  init_base: ->
    setup_options  = ember.merge {}, @default_setup_options
    @setup_options = ember.merge setup_options, @setup_options or {}
    @set_users()

  actions:
    prev:                 -> @send 'select', @get_user_from_offset(-1)
    next:                 -> @send 'select', @get_user_from_offset(1)
    select: (user)        -> @sendAction 'select', user or @get('current_user')
    toggle_show_dropdown: -> @toggleProperty 'show_dropdown'; return

  set_users: ->
    current_user = @get 'current_user'
    users        = @get('users')
    sorted_users = users.without(current_user).sortBy 'full_name'
    sorted_users.unshift(current_user)
    @set 'dropdown_users',  if @get_setup_option('include_current_user_in_dropdown')      then sorted_users else sorted_users.without(current_user)
    @set 'prev_next_users', if @get_setup_option('include_current_user_in_previous_next') then sorted_users else sorted_users.without(current_user)

  get_setup_option: (key) -> @setup_options and @setup_options[key]

  get_user_from_offset: (offset) ->
    current_user = @get('current_user')
    user    = @get('selected')
    users   = @get('prev_next_users')
    if ember.isPresent(user)
      index = users.indexOf(user)
      switch
        when index < 0 and offset > 0  then users.get('firstObject') # next past last
        when index < 0 and offset < 0  then users.get('lastObject')  # prev past first
        else
          offset_user = users.objectAt(index + offset)
          return offset_user if offset_user
          if offset > 0 then users.get('firstObject') else users.get('lastObject')
    else
      users.get('firstObject')

  # # ### TESTING ONLY
  # didInsertElement: ->
  #   user = @users.findBy 'first_name', 'read_1'
  #   @send 'select', user if user
