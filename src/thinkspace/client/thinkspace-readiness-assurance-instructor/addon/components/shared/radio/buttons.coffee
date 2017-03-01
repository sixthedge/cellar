import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'

export default base.extend
  tagName: 'div'

  actions:
    select: (id) -> @sendAction 'select', id

  willInsertElement: -> @process_button_columns()

  button_columns: null

  process_button_columns: ->
    ncols = @columns
    return unless (ncols and ncols > 1)
    buttons = @buttons or []
    return if ember.isBlank(buttons)
    per_col = Math.ceil(buttons.length / ncols)
    return if per_col < 1
    button_columns = []
    col_array      = []
    for button in buttons
      if col_array.length < per_col
        col_array.push(button)
      else
        button_columns.push(col_array)
        col_array = []
        col_array.push(button)
    button_columns.push(col_array) if ember.isPresent(col_array)
    @set 'button_columns', button_columns
