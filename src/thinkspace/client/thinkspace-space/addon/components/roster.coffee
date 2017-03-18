import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  students: null
  admins:   null

  columns: ember.computed ->
    [
      {display: 'Last Name',  property: 'last_name'},
      {display: 'First Name', property: 'first_name'},
      {display: 'Email',      property: 'email'},
      {display: 'I. Status',  property: 'invitation_status'},
      {display: 'Status',     component: 'roster/space_users/state', data: {space: @get('model')}}
    ]

  init_base: ->
    @set_students().then =>
      @set_admins().then =>
        @set_all_data_loaded()

  # Setters
  set_students: ->
    new ember.RSVP.Promise (resolve, reject) =>
      query   = @get_query_query()
      options = @get_query_options()
      @add_student_filters(query)
      @add_orders(query)
      @tc.query_paginated(ns.to_p('space'), query, options).then (students) =>
        @set('students', students)
        resolve()

  set_admins: ->
    new ember.RSVP.Promise (resolve, reject) =>
      query   = @get_query_query()
      options = @get_query_options()
      @add_admin_filters(query)
      @add_orders(query)
      @tc.query_paginated(ns.to_p('space'), query, options).then (admins) =>
        @set('admins', admins)
        resolve()

  # Query helpers
  get_query_query: ->
    id    = @get('model.id')
    query = 
      page:
        number: 1
        size:   5
      id: id

  get_query_options: ->
    options = 
      action: 'roster'
      model:  ns.to_p('user')

  # Filter helpers
  add_student_filters: (query) ->
    states_filter = @get_states_filter(['active'])
    roles_filter  = @get_roles_filter(['read'])
    @tc.add_filter_to_query(query, [states_filter, roles_filter])

  add_admin_filters: (query) ->
    states_filter = @get_states_filter(['active'])
    roles_filter  = @get_roles_filter(['owner', 'update'])
    @tc.add_filter_to_query(query, [states_filter, roles_filter])

  get_states_filter: (states) -> @tc.get_filter_array('scope_by_states', states)
  get_roles_filter: (roles) ->   @tc.get_filter_array('scope_by_roles', roles)

  # Order helpers
  add_orders: (query) ->
    orders = [{last_name: 'ASC', first_name: 'ASC'}]
    @tc.add_order_to_query(query, orders)

  actions:
    next: (type) ->
      users = @get(type)
      users.get_next_page()

    prev: (type) ->
      users = @get(type)
      users.get_prev_page()