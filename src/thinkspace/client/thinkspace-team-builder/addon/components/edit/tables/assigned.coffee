import ember  from 'ember'
import base   from 'thinkspace-team-builder/components/edit/tables/base'
import column from 'thinkspace-common/table/column'

## Component to handle rendering and actions for the edit component's assigned users
export default base.extend

  columns: ember.computed 'students', ->
    [
      column.create({display: 'Select', component: '__table/cells/selectable', data: {calling: @}}),
      column.create({display: 'Last Name', property: 'last_name'}),
      column.create({display: 'First Name', property: 'first_name'})
    ]

  actions:
    add_members: -> @sendAction('add_members')

    remove_members: -> 
      @sendAction('remove_members')
      @reset_selected_rows()