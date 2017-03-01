import ember from 'ember'

export default ember.Mixin.create

  current_date: -> new Date()

  mm_dd_yyyy: (d=@current_date()) ->
    mm   = @rjust(d.getMonth()+1,2,'0')
    dd   = @rjust(d.getDate(),2,'0')
    yyyy = d.getFullYear()
    "#{mm}/#{dd}/#{yyyy}"

  hh_ss_mm: (d=@current_date()) ->
    hh = @rjust(d.getHours(),2,'0')
    mm = @rjust(d.getMinutes(),2,'0')
    ss = @rjust(d.getSeconds(),2,'0')
    "#{hh}:#{mm}:#{ss}"

  date_time: (d=@current_date()) ->
    "#{@mm_dd_yyyy(d)} #{@hh_ss_mm(d)}"

  date_time_milliseconds: (d=@current_date()) ->
    "#{@date_time(d)}:#{@rjust(d.getMilliseconds(),3,'0')}"

  convert_time_string_to_milliseconds: (string) ->
    return null unless string and typeof(string) == 'string'
    [number_of, units] = string.split('.')
    return null if number_of.match(/\D/)
    switch units
      when 'seconds', 'second'
        number_of * 1000
      when 'minutes', 'minute'
        number_of * 60000
      when 'hours', 'hour'
        number_of * 3600000
      else
        null
