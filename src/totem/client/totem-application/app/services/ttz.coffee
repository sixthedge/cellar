import ember from 'ember'
import us_tz from './ttz/zones/us'

export default ember.Service.extend
  zone_files:        [us_tz]
  current_time_zone: ''
  zones:             []

  init: ->
    @_super()
    @map_zones()

  map_zones: ->
    zones = []
    @get('zone_files').forEach (file) =>
      zones.pushObject file.get('zones')
    zones = [].concat.apply([], zones) # Flatten
    @set('zones', zones)

  format: (time, options) ->
    return @error("Cannot format a time without passing in a time.") unless @is_present(time)
    zone      = @get_zone(options) if @is_present(options)
    cast_zone = @get_cast_zone(options) if @is_present(options)
    time      = @cast_time(time, cast_zone) if @is_present(cast_zone)
    if @is_present(zone) then time = moment.tz(time, zone) else time = moment(time)   
    time = time.format(options.format) if @is_present(options.format)
    time

  # TODO: Implement force for zone.
  get_zone: (options) ->
    return @get('current_time_zone') if @is_present(@get('current_time_zone'))
    return options.zone                          if @is_present(options.zone)
    return @iana_from_friendly(options.friendly) if @is_present(options.friendly)
    return @iana_from_alt(options.alt)           if @is_present(options.alt)
    null

  get_cast_zone: (options) ->
    return options.cast_zone                               if @is_present(options.cast_zone)
    return @iana_from_friendly(options.cast_zone_friendly) if @is_present(options.cast_zone_friendly)
    return @iana_from_alt(options.cast_zone_alt)           if @is_present(options.cast_zone_alt)
    null

  # Remove the timezone from current `time` and change it to `zone` keeping hours/day/etc intact.
  cast_time: (time, zone) ->
    moment_time = moment(time)
    dup_time    = moment_time.clone()
    dup_time    = moment.tz(dup_time, zone)
    offset      = moment_time.utcOffset() - dup_time.utcOffset()
    dup_time.add(offset, 'minutes')
    dup_time

  get_client_zone_iana: -> 
    return if ember.isPresent(Intl.DateTimeFormat().resolved) then Intl.DateTimeFormat().resolved.timeZone else 'America/Chicago'

  get_client_zone_alt: ->
    @alt_from_iana(@get_client_zone_iana())

  abbr_from_iana: (iana) ->
    moment.tz(iana).zoneAbbr()

  abbr_from_friendly: (friendly) ->
    iana = @iana_from_friendly(friendly)
    @abbr_from_iana(iana)

  iana_from_friendly: (friendly) ->
    zone = @find_by_zone_property('friendly', friendly)
    if ember.isPresent(zone) then zone.iana else null

  iana_from_alt: (alt) ->
    alt     = alt.toLowerCase()
    results = @get('zones').filter (zone) =>
      zone.alt.contains(alt)
    console.warn "Returning first of a set of time zones for alternate filter." if results.get('length') > 1
    if ember.isEmpty(results)
      console.error "No time zone found for given alternate [#{alt}]."
      return null
    results.get('firstObject').iana

  alt_from_iana: (iana) ->
    results = @get('zones').filterBy('iana', iana)
    console.warn "Returning first of a set of time zones for alternate filter." if results.get('length') > 1
    if ember.isEmpty(results)
      console.error "No alt found from given iana [#{iana}]"
      return null
    results.get('firstObject.alt.firstObject')

  find_by_zone_property: (property, value) ->
    @get('zones').findBy(property, value)

  set_current_time_zone: (zone) ->
    @set('current_time_zone', zone)

  set_date_to_time: (date, time) ->
    # Time is coming from pickatime.
    # => {hour: Integer, mins: Integer, time: Integer}
    hour = time.hour or 0
    mins = time.mins or 0 
    date.setHours(hour)
    date.setMinutes(mins)
    date.setSeconds(0)
    date.setMilliseconds(0)
    date

  is_present: (value) ->
    ember.isPresent(value)

  error: (message) ->
    console.error "[ttz] #{message}"