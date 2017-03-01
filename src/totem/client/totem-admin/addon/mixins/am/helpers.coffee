import ember from 'ember'
import util  from 'totem/util'

export default ember.Mixin.create

  get_platform: -> @get('config.pub_sub.namespace') or 'unknown'

  pluralize: (count, singular, plural=null) -> if count == 1 then singular else (plural or singular.pluralize())

  server_error_message: (error) -> error.responseJSON.errors.debug.message

  set_header_link_active:   (link) -> @find_header_link(link).addClass('active')
  set_header_link_inactive: (link) -> @find_header_link(link).removeClass('active')
  find_header_link:         (link) -> @get_header_links().find("[href='/admin/#{link}']")
  get_header_links: -> $('.totem-admin-header .totem-admin-link')

  set_other_header_links_inactvie: (link) ->
    $other_links = @get_header_links().find("[href!='/admin/#{link}']")
    $other_links.removeClass('active')

  # ###
  # ### Date/Time Helpers.
  # ###

  is_date: (obj) -> obj and (obj instanceof(Date))

  clone_date: (date) -> new Date(date.valueOf())

  format_time: (time) ->  @ttz.format((time or new Date()), format: 'MMM Do, h:mm a')

  format_time_only: (time) ->  @ttz.format((time or new Date()), format: 'h:mm a')

  format_seconds: (seconds) ->
    date = new Date()
    date.setHours(0,0,0,0)
    date.setSeconds(seconds)
    hh = util.rjust(date.getHours(),2,'0')
    mm = util.rjust(date.getMinutes(),2,'0')
    ss = util.rjust(date.getSeconds(),2,'0')
    "#{hh}:#{mm}:#{ss}"

  date_to_hh_mm: (date) -> @ttz.format(date, format: 'h:mm a')

  date_from_now: (date) ->
    zdate = @ttz.format(date, {})
    moment(zdate).fromNow()

  seconds_from_now: (date) -> Math.floor ( ( (+date) - (+new Date()) ) / 1000 )
  seconds_to_now:   (date) -> Math.floor ( ( (+new Date()) - (+date) ) / 1000 )

  minutes_from_now: (date) -> Math.floor ( ( (+date) - (+new Date()) ) / 60000 )
  minutes_to_now:   (date) -> Math.floor ( ( (+new Date()) - (+date) ) / 60000 )

  seconds_between_dates: (date1, date2) -> Math.floor ( ( (+date1) - (+date2) ) / 1000 )
  minutes_between_dates: (date1, date2) -> Math.floor ( ( (+date1) - (+date2) ) / 60000 )

  adjust_by_minutes: (date, mins) -> date.setMinutes(date.getMinutes() + mins)
