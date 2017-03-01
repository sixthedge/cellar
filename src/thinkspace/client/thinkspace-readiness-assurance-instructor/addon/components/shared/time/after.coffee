import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'

export default base.extend

  after_buttons:    null
  selected_minutes: null

  init_base: ->
    @set_after_buttons()
    ember.defineProperty @, 'show_formatted', ember.computed "rad.#{@time}", -> ember.isPresent(@formatted) and ember.isPresent(@get("rad.#{@time}"))
    ember.defineProperty @, 'formatted_time', ember.computed.reads "rad.#{@time}_formatted"
    @validate = @rad.validate

  set_after_buttons: ->
    buttons = []
    range = @range or {start: 1, end: 5, by: 1}
    for hash in ember.makeArray(range)
      start = hash.start
      end   = hash.end
      b     = hash.by
      if start and end and b
        n       = Math.floor( (end - start) / b) + 1
        running = start
        for i in [1..n]
          running += b unless i == 1
          label = @am.pluralize(running, 'minute')
          buttons.push(id: running, label: "#{running} #{label}")
    @set 'after_buttons', buttons

  actions:
    select: (minutes) ->
      @set 'selected_minutes', minutes
      after_at = new Date()
      @am.adjust_by_minutes(after_at, minutes)
      @rad.set @time, after_at
      @rad.set "#{@time}_formatted", @am.format_time_only(after_at)
      @sendAction 'validate' if @validate
