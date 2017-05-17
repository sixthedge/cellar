import ember  from 'ember'
import config from 'totem-config/config'
import base   from 'thinkspace-user/components/sign_up'

export default base.extend
  # # Properties
  terms_url: config.urls.terms
  
  # ## Radio options  
  role: null
  role_options:
    group:
      label: 'Are you an instructor or a student?*'
    choices: [
      {label: "I'm a student", value: 'student'},
      {label: "I'm an instructor", value: 'instructor'}
    ]

  # # Helpers
  toggle_role: (role) ->
    changeset = @get('changeset')
    switch role
      when 'student'
        @set('role', 'student')
        changeset.set('roles', {student: true, instructor: false})
      when 'instructor'
        @set('role', 'instructor')
        changeset.set('roles', {student: false, instructor: true})

  actions:
    changed_role: (role) -> @toggle_role(role)