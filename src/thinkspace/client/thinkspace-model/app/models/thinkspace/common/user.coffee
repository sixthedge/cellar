import ember from 'ember'
import ta from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.has_many 'spaces', inverse: ta.to_p('users')
    ta.has_many 'space_users'
  ),

  email:        ta.attr('string')
  first_name:   ta.attr('string')
  last_name:    ta.attr('string')
  state:        ta.attr('string')
  password:     ta.attr('string') # Used in sign_up only.
  token:        ta.attr('string') # Used in sign_up only.
  activated_at: ta.attr('date')
  profile:      ta.attr()


  full_name:     ember.computed 'first_name', 'last_name', ->
    first_name = @get('first_name') or '?'
    last_name  = @get('last_name')  or '?'
    "#{first_name} #{last_name}"
  sort_name:     ember.computed -> "#{@get('last_name')}, #{@get('first_name')}"
  html_title:    ember.computed -> "#{@get('full_name')} - #{@get('email')}"
  first_initial: ember.computed 'first_name', -> @get_initial_from_name(@get('first_name'))
  last_initial:  ember.computed 'last_name', -> @get_initial_from_name(@get('last_name'))
  display_name:  ember.computed.reads 'full_name'
  initials:      ember.computed 'first_name', 'last_name', -> "#{@get('first_initial')} #{@get('last_initial')}"
  color_string:  ember.computed 'initials', -> "#{@get('initials')}-#{@get('id')}"
  color:         'eeeeee'

  invitation_status: ember.computed 'state', -> 
    return 'Yes' if @get('is_active')
    return 'No'  if @get('is_inactive')

  is_active:   ember.computed.equal 'state', 'active'
  is_inactive: ember.computed.equal 'state', 'inactive'

  get_initial_from_name: (name) ->
    return '?' unless ember.isPresent(name)
    name.charAt(0).capitalize()

  # ### Profile
  is_student: ember.computed 'profile.roles', ->
    @has_profile_role('student')
  is_teacher: ember.computed 'profile.roles', ->
    @has_profile_role('teacher')

  has_profile_role: (role) ->
    roles = @get('profile.roles')
    return false unless ember.isPresent(roles)
    roles.includes(role)
