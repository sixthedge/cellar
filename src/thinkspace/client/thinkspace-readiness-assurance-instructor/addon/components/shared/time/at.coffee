import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'

export default base.extend

  can_clear:   ember.computed 'selected_at', -> @clearable != false and ember.isPresent(@get('selected_at'))
  show_select: true

  init_base: ->
    @set_time_options()
    @selected_at = @rad.get(@time)
    @validate    = @rad.validate

  actions:
    clear: -> @set_time(null)

    select: (time) ->
      return if ember.isBlank(time)
      at = @get_time_at()
      at = @am.ttz.set_date_to_time(at, time)
      @set_time(at)

  set_time: (time) ->
    @set 'selected_at', time
    @set_rad(time)
    @sendAction 'validate' if @validate

  set_time_options: ->
    interval = parseInt(@get_rad('interval') or 1)
    min      = @get_min(interval)
    max      = @get_max(interval)
    clear    = @get_rad('clear') or ''
    @set 'time_options', {interval, min, max, clear}
    @sendAction 'validate' if @validate

  get_min: (int) ->
    min = @get_rad('min') or 0
    if @am.is_date(min)
      min_at = @am.clone_date(min)
    else
      min_at = @get_time_at()
      @am.adjust_by_minutes(min_at, (min*int)+1)
      @am.round_up_minutes(min_at, int)
    min_at

  get_max: (int) ->
    max = @get_rad('max') or 0
    if @am.is_date(max)
      max_at = @am.clone_date(max)
    else
      max_at = @get_time_at()
      @am.adjust_by_minutes(max_at, (max*int)-1)
      @am.round_down_minutes(max_at, int)
    max_at

  get_time_at: -> @am.clone_date(@time_at or @rad.time_at)

  get_rad: (key) -> @rad.get "#{@time}_#{key}"
  set_rad: (val) -> @rad.set @time, val
