import ember  from 'ember'
import base   from 'totem-base/components/base'
import m_sort_by from 'totem-application/mixins/table_sort_by'

export default base.extend m_sort_by,

  admin: ember.inject.service()

  ready:             false
  user_data:         null
  has_tracker_users: false

  sorted_user_data: ember.computed.sort 'user_data', 'sort_by'

  sort: ember.computed ->
    sort_configs =
      user:     {id: 'user', sort: 'sort_username', text: 'User'}
      route:    {id: 'route', sort: 'route', text: 'Route'}
      date:     {id: 'date', sort: 'date', text: 'Last Date'}
      date1:    {id: 'date1', sort: 'date1', text: 'Initial Date'}
      lastdiff: {id: 'lastdiff', sort: 'lastdiff', text: 'Since Last'}
      elapsed:  {id: 'elapsed', sort: 'elapsed_time', text: 'Elapsed'}
      title:    {id: 'title', sort: 'sort_model_title', text: 'Title'}
      model:    {id: 'model', sort: ['model_name', 'model_id'], text: 'Model'}
      url:      {id: 'url', sort: 'sort_url', text: 'URL'}

  actions:
    refresh: -> @am.emit_tracker_show(@)

  init: ->
    @_super(arguments...)
    @am        = @get('admin')
    @ttz       = @get('ttz')
    @user_data = null
    @set_default_sort_by ['user', 'route']
    @am.tracker_show(@)

  didInsertElement: -> @get('admin').set_other_header_links_inactvie('tracker')

  handle_tracker_show: (data) ->
    console.info '=> tracker show', data
    track_users = data.value or []
    users       = []
    for hash in track_users
      users.push @get_tracked_user_hash(hash)
    @set 'user_data', users
    @set 'has_tracker_users', ember.isPresent(users)
    @notifyPropertyChange 'sorted_user_data'
    @set 'ready', true

  get_tracked_user_hash: (hash) ->
    user              = hash.user or {}
    data              = hash.data or {}
    id                = user.id
    username          = user.username
    url               = hash.href
    date              = hash.date
    date1             = hash.date1
    prev_date         = hash.prev_date or date
    show_date         = @get_show_date(date)
    show_date1        = @get_show_date(date1)
    elapsed_time      = @get_seconds_to_now(date1)
    show_elapsed_time = @get_show_time(elapsed_time)
    lastdiff          = @get_date_diff(prev_date, date)
    show_lastdiff     = @get_show_time(lastdiff)
    model_name        = data.model_name
    model_id          = data.id
    model_title       = data.title or ''
    route             = data.route
    show_model_name   = if ember.isPresent(model_name) then "#{model_name}/#{model_id}" else ''
    @make_hash_sortable {id, username, route, date, show_date, date1, show_date1, url, model_name, show_model_name, model_title, model_id, elapsed_time, show_elapsed_time, lastdiff, show_lastdiff}

  get_seconds_to_now: (date) -> if ember.isBlank(date) then null else @am.seconds_to_now(@am.clone_date(date))

  get_date_diff: (start_date, end_date) ->
    return null if ember.isBlank(start_date) or ember.isBlank(end_date)
    @am.seconds_between_dates(@am.clone_date(end_date), @am.clone_date(start_date))

  get_show_time: (seconds) ->
    return null if ember.isBlank(seconds)
    @am.format_seconds(seconds)

  get_show_date: (date) ->
    return null if ember.isBlank(date)
    @am.format_time(date)

  make_hash_sortable: (hash) ->
    hash.sort_username    = (hash.username or '').toLowerCase()
    hash.sort_model_title = (hash.model_title or '').toLowerCase()
    hash.sort_url         = (hash.url or '').toLowerCase()
    hash
