import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'

export default base.extend

  init_base: ->
    @reset_timer()
    # @set 'add_reminder', true # TESTING ONLY

  time_change: ember.observer 'time_at', -> @set_have_time_for_reminder()

  willInsertElement: -> @set_have_time_for_reminder()

  reset_timer: ->
    @set 'add_reminder', false
    @set 'have_time_for_reminder', true
    @set 'interval', null
    @set 'reminders', null
    @start_at = null
    @end_at   = null

  set_have_time_for_reminder: ->
    return false if ember.isBlank(@time_at)
    min = @am.minutes_from_now(@time_at)
    @set 'have_time_for_reminder', min > 0

  actions:
    select_reminder:    -> @set 'add_reminder', true
    select_no_reminder: -> @reset_timer(); @set_timer()

    select_interval:   (int) -> @set 'interval', int;   @set_timer()
    select_reminders: (num)  -> @set 'reminders', num;  @set_dates()

    clear_interval: -> @set 'interval', null

    clear_reminder: ->
      @reset_timer()
      @set 'have_time_for_reminder', false
      @set_timer()

  set_dates: ->
    return if ember.isBlank(@interval) or ember.isBlank(@reminders)
    mins      = (@interval * @reminders) * -1
    @end_at   = @am.clone_date(@time_at)
    @start_at = @am.clone_date(@time_at)
    @am.adjust_by_minutes(@start_at, mins)
    @set_timer()

  set_timer: ->
    interval = @get('interval')
    options  = null
    if @add_reminder and ember.isPresent(interval)
      type     = @rad.get('timer_type')
      unit     = @rad.get('timer_unit')
      settings = {type, unit, interval}
      options  = {settings, @start_at, @end_at}
    @rad.set_timer(options)
