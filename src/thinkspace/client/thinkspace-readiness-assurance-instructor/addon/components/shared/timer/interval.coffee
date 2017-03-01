import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'

export default base.extend

  selected_id:      null
  interval_buttons: null

  time_change: ember.observer 'time_at', -> @set_interval_buttons()

  willInsertElement: -> @set_interval_buttons()

  actions:
    select: (id) ->
      @set 'selected_id', id
      @sendAction 'select', id
      @set_interval_buttons()

  set_interval_buttons: ->
    max  = @get('intervals') or 5
    mins = @am.minutes_from_now(@time_at)
    if mins <= 0
      @set 'interval_buttons', null
      @set 'selected_id', null
      @sendAction 'clear'
      return
    mins = max if mins > max
    buttons = []
    for i in [1..mins]
      label = @am.pluralize(i, 'minute')
      buttons.push(id: i, label: "#{i} #{label}")
    if buttons.length == 1
      id = buttons[0].id
      @set 'selected_id', id
      @sendAction 'select', id
    else
      if @selected_id and @selected_id > mins
        @set 'selected_id', null
        @sendAction 'select', null
    @set 'interval_buttons', buttons
