import ember           from 'ember'
import ns              from 'totem/ns'
import totem_changeset from 'totem/changeset'
import base            from 'thinkspace-base/components/base'

export default base.extend
  # # Properties
  changeset: null

  # ## Direct invitation properties
  role_options:
    group:
      label: 'Is this user a student, teaching assistant, or instructor?'
    choices: [
      {label: 'Student', value: 'read'},
      {label: 'Teaching Assistant', value: 'update'},
      {label: 'Instructor', value: 'owner'}
    ]

  # # Events
  init_base: ->
    @set_changeset()

  # # Helpers
  set_changeset: ->
    model = ember.Object.create(email: null, role: 'read')
    changeset = totem_changeset.create model,
      email: [
        totem_changeset.vpresence(presence: true, message: 'You must enter an email'),
        totem_changeset.vformat(type: 'email', message: 'You must enter a valid email')
      ]
      role: [totem_changeset.vpresence(presence: true)]
    changeset.set('role', 'read') # Default to student
    @set('changeset', changeset)

  actions: 
    changed_role: (role) -> @get('changeset').set('role', role)
    submit: ->
      changeset = @get('changeset')
      changeset.validate().then =>
        if changeset.get('is_valid')
          email     = changeset.get('email')
          role      = changeset.get('role')
          query     = 
            email: email
            role:  role
            id:    @get('model.id')
          options = 
            action: 'invite'
            verb:   'POST'
          @tc.query_action(ns.to_p('space'), query, options).then =>
            @get('thinkspace').transition_to_route('spaces.roster')
            @totem_messages.api_success source: @, model: @get('model'), action: 'invited'
        else
          changeset.show_errors_on()