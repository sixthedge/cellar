import ember       from 'ember'
import ns          from 'totem/ns'
import base        from 'thinkspace-base/components/base'
import totem_scope from 'totem/scope'

export default base.extend
  role: null
  role_options:
    group:
      label: 'Are you an instructor or a student?'
    choices: [
      {label: "I'm a student", value: 'student'},
      {label: "I'm an instructor", value: 'instructor'}
    ]

  first_name: ember.computed.reads 'model.first_name'
  last_name:  ember.computed.reads 'model.last_name'
  is_teacher: ember.computed.reads 'session.user.is_teacher'

  init_base: ->
    @init_student()
    @init_role()

  init_role: ->
    model = @get('model')
    roles = model.get('profile.roles')
    if ember.isPresent(roles)
      if roles.student
        @set('role', 'student')
      else if roles.instructor
        @set('role', 'instructor')

  init_student: ->
    @set('model', totem_scope.get_current_user())

  # # Helpers
  toggle_role: (role) ->
    model = @get('model')
    switch role
      when 'student'
        @set('role', 'student')
        model.set('profile.roles', {student: true, instructor: false})
      when 'instructor'
        @set('role', 'instructor')
        model.set('profile.roles', {student: false, instructor: true})

  set_names: ->
    first_name = @get('first_name')
    last_name  = @get('last_name')
    model      = @get('model')
    model.set('first_name', first_name)
    model.set('last_name', last_name)

  actions:
    changed_role: (role) -> @toggle_role(role)

    update: -> 
      @set_names()
      model = @get('model')
      model.save().then =>
        location.reload(true)
