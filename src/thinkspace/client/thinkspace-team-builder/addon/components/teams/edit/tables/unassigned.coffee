import ember  from 'ember'
import column from 'totem-table/table/column'
import base   from 'thinkspace-team-builder/components/teams/edit/tables/base'

## Component to handle rendering and actions for the edit component's assigned users
export default base.extend

  columns: ember.computed 'students', ->
    [
      column.create({display: 'Select', component: '__table/cells/selectable', data: {calling: {component: @, register: true}}}),
      column.create({display: 'Last Name', property: 'last_name'}),
      column.create({display: 'First Name', property: 'first_name'})
    ]

  actions:
    add_selected: -> @sendAction('add_selected')

    cancel: -> @sendAction('cancel')