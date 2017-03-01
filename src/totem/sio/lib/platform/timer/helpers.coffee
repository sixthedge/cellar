class SocketIOTimerHelpers

  constructor: (@timer) -> @util = @timer.util

  data_timer:   (data) -> data.timer or {}
  data_id:      (data) -> @data_timer(data).id or 'none'
  data_type:    (data) -> @data_timer(data).type or null
  data_title:   (data) -> @data_timer(data).title or 'no title'
  data_unit:    (data) -> @data_timer(data).unit or null
  data_event:   (data) -> @data_timer(data).room_event
  data_user_id: (data) -> @data_timer(data).user_id or null
  data_message: (data) -> @data_timer(data).message or null

  data_cancel_ids: (data) ->
    ids = @data_timer(data).cancel_id or @data_timer(data).cancel_ids
    return [] unless ids
    @util.make_array(ids)

  data_interval: (data) ->
    ms  = @data_milliseconds(data)
    inc = @data_timer(data).interval
    return null unless (ms and inc)
    parseInt(inc) * ms

  data_milliseconds: (data) ->
    unit = @data_unit(data) or 'minute'
    switch unit
      when 'second'  then 1000
      when 'minute'  then 60000
      else null

  data_end_at: (data) ->
    end_at = @data_timer(data).end_at
    return null unless @util.is_string(end_at)
    new Date(end_at)

  data_start_at: (data) ->
    start_at = @data_timer(data).start_at
    return null unless @util.is_string(start_at)
    start_at = new Date(start_at)
    return null if start_at < (new Date())
    start_at

  timeout_value: (date) ->
    return null unless @is_date(date)
    current_date = new Date()
    current_date.setMilliseconds(0)
    cdate = @clone_date(date)
    cdate.setMilliseconds(0)
    return null unless cdate > current_date
    dif = cdate - current_date
    return null unless dif > 0
    dif

  clone_hash: (hash, except...) ->
    return {} unless @util.is_hash(hash)
    nhash      = {}
    has_except = @util.is_array_present(except)
    for own k, v of hash
      if has_except
        nhash[k] = v unless @util.array_contains(except, k)
      else
        nhash[k] = v
    nhash

  is_date:    (date) -> date and (date instanceof(Date))
  clone_date: (date) -> new Date(date.valueOf())

  get_child_id: (obj, id) -> @get_object_keys_length(obj) + 1

  get_object_keys_length: (obj) -> @util.hash_keys(obj).length

  debug: (timer) ->
    sep = @util.sep()
    now = new Date()
    @util.blank_line()
    @util.debug @util.bold_line("TIMER #{timer.type} emit:" + sep, 'magenta')
    @util.say timer.emit
    msg = []
    msg.push 'id     :' + timer.id + '; uid:' + timer.uid + '; title:' + timer.title
    msg.push 'now    :' + now
    msg.push 'end_at :' + timer.end_at + '; start_at:' + timer.start_at
    msg.push 'timeout: ' + timer.timeout + ' running: ' + timer.running + ' total: ' + timer.total_timeout + ' interval: ' + timer.inc + ' final:' + timer.final
    @util.say '  ' + msg.join("\n  ")
    @util.say @util.color_line(sep, 'magenta')

  to_string: -> 'SocketIOTimerHelpers'

module.exports = SocketIOTimerHelpers
