import ember       from 'ember'
import totem_scope from 'totem/scope'

export default ember.Mixin.create

  get_store: -> totem_scope.get_store()

  get_auth_query: (url, data={}) ->
    verb  = 'post'
    query = {url, verb, data}
    @add_auth_to_query(query)
    query

  add_auth_to_query: (query) -> totem_scope.add_auth_to_ajax_query(query)

  current_user_message_name: -> totem_scope.get_current_user().get('full_name')

  pluralize: (count, singular, plural=null) -> if count == 1 then singular else (plural or singular.pluralize())

  get_username: (user) -> "#{user.last_name}, #{user.first_name}"

  # ###
  # ### Date/Time Helpers.
  # ###

  is_date: (obj) -> obj and (obj instanceof(Date))

  clone_date: (date) -> new Date(date.valueOf())

  format_time: (time) ->  @ttz.format((time or new Date()), format: 'MMM Do, h:mm a')

  format_time_only: (time) ->  @ttz.format((time or new Date()), format: 'h:mm a')

  date_to_hh_mm: (date) -> @ttz.format(date, format: 'h:mm a')

  date_from_now: (date) ->
    zdate = @ttz.format(date, {})
    moment(zdate).fromNow()
  
  minutes_from_now: (date) -> Math.floor ( ( (+date) - (+new Date()) ) / 60000 )

  minutes_from_now_message: (mins) -> mins + ' minute' + (if mins==1 then '' else 's')

  minutes_between_dates: (date1, date2) -> Math.floor ( ( (+date1) - (+date2) ) / 60000 )
  
  adjust_by_minutes: (date, mins) -> date.setMinutes(date.getMinutes() + mins)

  round_minutes: (date, int) ->
    return if ember.isBlank(date) or ember.isBlank(int)
    minutes = date.getMinutes()
    minutes = Math.round(minutes / int) * int
    date.setMinutes(minutes)

  round_down_minutes: (date, int) ->
    return if ember.isBlank(date) or ember.isBlank(int)
    minutes = date.getMinutes()
    minutes = Math.floor(minutes / int) * int
    date.setMinutes(minutes)

  round_up_minutes: (date, int) ->
    return if ember.isBlank(date) or ember.isBlank(int)
    minutes = date.getMinutes()
    minutes = Math.ceil(minutes / int) * int
    date.setMinutes(minutes)
