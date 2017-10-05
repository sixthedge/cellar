import ember  from 'ember'
import ns     from 'totem/ns'
import column from 'totem-table/table/column'
import base   from 'thinkspace-base/components/base'

export default base.extend
  # # Properties
  students: null
  admins:   null

  # # Computed properties
  student_columns: ember.computed -> @get_columns()
  student_data:    ember.computed -> { source: @, sort: 'student_sort' }

  admin_columns: ember.computed -> @get_columns()
  admin_data:    ember.computed -> { source: @, sort: 'admin_sort' }

  has_students: ember.computed.notEmpty 'students'
  has_admins:   ember.computed.notEmpty 'admins'

  # # Events
  init_base: ->
    @set_students().then =>
      @set_admins().then =>
        @set_all_data_loaded()

  # # Helpers
  # ## Sorting/column helpers
  get_columns: ->
    [
      column.create({display: 'Last Name',      property: 'last_name', direction: 'ASC'})
      column.create({display: 'First Name',     property: 'first_name'}),
      column.create({display: 'Email',          property: 'email'}),
      column.create({display: 'Has Logged In?', property: 'invitation_status', sortable: false}),
      column.create({display: 'Resend Invite',  component: 'roster/space_users/resend', sortable: false, data: {space: @get('model')}} ),
    ]

  student_sort: (column) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return reject() unless column.get('has_property')
      property  = column.get_property()
      direction = column.invert_direction()
      @get_students(property: property, direction: direction).then (students) =>
        resolve(students)

  admin_sort: (column) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return reject() unless column.get('has_property')
      property  = column.get_property()
      direction = column.invert_direction()
      @get_admins(property: property, direction: direction).then (admins) =>
        resolve(admins)

  # ## Getters/setters
  get_students: (settings={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      query   = @get_query_query()
      options = @get_query_options()
      @add_student_filters(query, settings)
      @add_sorts(query, settings)
      @tc.query_paginated(ns.to_p('space'), query, options).then (students) =>
        resolve(students)

  set_students: (settings={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @get_students(settings).then (students) =>
        @set('students', students)
        resolve()

  get_admins: (settings={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      query   = @get_query_query()
      options = @get_query_options()
      @add_admin_filters(query)
      @add_sorts(query)
      @tc.query_paginated(ns.to_p('space'), query, options).then (admins) =>
        resolve(admins)

  set_admins: (settings={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @get_admins(settings).then (admins) =>
        @set('admins', admins)
        resolve()

  # ## Query helpers
  get_query_query: ->
    id    = @get('model.id')
    query = 
      page:
        number: 1
        size:   10
      id: id

  get_query_options: ->
    options = 
      action: 'roster'
      model:  ns.to_p('user')

  # ### Filter query helpers
  add_student_filters: (query, options={}) ->
    states_filter = @get_states_filter(['active'])
    roles_filter  = @get_roles_filter(['read'])
    @tc.add_filter_to_query(query, [states_filter, roles_filter])

  add_admin_filters: (query) ->
    states_filter = @get_states_filter(['active'])
    roles_filter  = @get_roles_filter(['owner', 'update'])
    @tc.add_filter_to_query(query, [states_filter, roles_filter])

  get_states_filter: (states) -> @tc.get_filter_array('scope_by_states', states)
  get_roles_filter: (roles) ->   @tc.get_filter_array('scope_by_roles', roles)

  # ### Sort query helpers
  add_sorts: (query, options={}) ->
    direction = options.direction || 'ASC'
    property  = options.property || 'last_name'
    sorts     = [{"#{property}": direction}]
    @tc.add_sort_to_query(query, sorts)
