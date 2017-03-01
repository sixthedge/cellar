import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'

export default base.extend

  selected_id: null
  button_rows: null

  interval_change: ember.observer 'interval', 'time_at', -> @set_reminder_buttons()

  willInsertElement: -> @set_reminder_buttons()

  actions:
    select: (id) ->
      @set 'selected_id', id
      @sendAction 'select', id
      @set_reminder_buttons()

  set_reminder_buttons: ->
    max  = @max or 5
    mins = @am.minutes_from_now(@time_at)
    n    = @get_number_of_reminders()
    if mins <= 0
      @set 'reminder_buttons', null
      @set 'selected_id', null
      @sendAction 'clear'
      return
    if n <= 0
      @set 'reminder_buttons', null
      @set 'selected_id', null
      @sendAction 'select', null
      return
    buttons = []
    for i in [1..n]
      label = @am.pluralize(i, 'reminder')
      buttons.push(id: i, label: "#{i} #{label}")
    if buttons.length == 1 or ember.isBlank @get('selected_id')
      id = buttons[0].id
      @set 'selected_id', id
      @sendAction 'select', id
    else
      if @selected_id and @selected_id > mins
        @set 'selected_id', null
        @sendAction 'select', null
    @set 'reminder_buttons', buttons

  get_number_of_reminders: ->
    max  = @max or 5
    int  = parseInt(@interval)
    mins = @am.minutes_from_now(@time_at) or 0
    n    = Math.floor(mins / int)
    if n > max then max else n
