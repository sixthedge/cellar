import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend
  # ### Services
  ttz: ember.inject.service()

  init_base: ->
    value = @get('value')
    @set 'datetime', value

  set_date: (date) -> 
    @set 'date', date.obj
    @set_datetime()
  set_time: (time) -> 
    @set 'time', time
    @set_datetime()

  coalesce: ->
    date = @get 'date'
    time = @get 'time'
    return date unless ember.isPresent(time) # assume [date] @ midnight if no time present
    return @get('ttz').set_date_to_time(new Date(), time) unless ember.isPresent(date) # assume today @ [time] if no date present
    datetime = @get('ttz').set_date_to_time date, time
    datetime = new Date(datetime.getTime())

  set_datetime: -> @set 'datetime', @coalesce()
  get_datetime: -> @get 'datetime'

  actions:

    select_date: (date) -> 
      @set_date(date)
      datetime = @get_datetime()
      @sendAction 'select', datetime

    select_time: (time) -> 
      @set_time(time)
      datetime = @get_datetime()
      @sendAction 'select', datetime