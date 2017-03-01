import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'

export default base.extend

  user_data:         null
  has_tracker_users: false
  sorted_by:         'username'

  sort_by: ['sort_username']
  sorted_user_data: ember.computed.sort 'user_data', 'sort_by'

  actions:
    by_user:    -> @set_sort_by 'username',  ['sort_username']
    by_tracked: -> @set_sort_by 'tracked',   ['tracked', 'sort_username']
    by_date:    -> @set_sort_by 'date',      ['date:desc', 'sort_username']
    by_teams:   -> @set_sort_by 'teams',     ['sort_teams', 'tracked:desc', 'sort_username']
    by_title:   -> @set_sort_by 'title',     ['sort_model_title', 'sort_username']
    by_url:     -> @set_sort_by 'url',       ['url', 'sort_username']

  set_sort_by: (sorted_by, sort_by_array) ->
    @set 'sort_by', sort_by_array
    @set 'sorted_by', sorted_by # could be used in computed properties to highlight column being sorted

  init_base: ->
    @room = @se.get_tracker_room()
    @am.send_tracker({@room}).then =>
      @pubsub_tracker_show()
      @emit_tracker_show()

  pubsub_tracker_show: -> @pubsub.tracker_show(room: @room, source: @, callback: 'handle_tracker_show', after_authorize_callback: 'emit_tracker_show')

  emit_tracker_show: -> @pubsub.emit_tracker_show({@room})

  handle_tracker_show: (data)  -> @set_track_users(data)

  set_track_users: (data) ->
    console.info '=> tracker show', data
    track_users = data.value or []
    users       = []
    @am.get_trat_user_teams().then (user_teams) =>
      for user in user_teams
        user_id    = user.user.id
        # IDs in `track_users` are a string.
        track_user = track_users.findBy 'user.id', user_id.toString()
        if ember.isBlank(track_user)
          teams = @get_user_teams(user.teams)
          hash  = 
            username:    @am.get_username(user.user)
            teams:       teams
            tracked:     'no'
            untracked:   true
          @make_hash_sort_last(hash)
          users.push @make_hash_sortable(hash)
        else
          track_user.teams = user.teams
          users.push @get_tracked_user_hash(track_user)
      @set 'user_data', users
      @set 'has_tracker_users', ember.isPresent(users)
      @set_ready_on()

  get_tracked_user_hash: (hash) ->
    tracked     = 'yes'
    user        = hash.user or {}
    data        = hash.data or {}
    id          = user.id
    username    = @am.get_username(user)
    href        = hash.href
    teams       = @get_user_teams(hash.teams)
    date        = hash.date
    date        = if date then @am.format_time(date) else null
    model_name  = @get_tracker_model_name(data)
    model_id    = data.id
    url         = if ember.isBlank(model_name) then '' else "#{model_name}/#{model_id}"
    model_title = data.title or ''
    @make_hash_sortable {id, username, tracked, url, teams, date, model_name, model_title, model_id}

  get_user_teams: (teams) -> (teams or []).mapBy('title').join(',')

  make_hash_sortable: (hash) ->
    hash.sort_username    = (hash.username or '').toLowerCase()
    hash.sort_teams       = (hash.teams or '').toLowerCase()
    hash.sort_model_title = (hash.model_title or '').toLowerCase()
    hash

  make_hash_sort_last: (hash, sort_last='zzzzzzzzzzzzzzzz') ->
    hash.url         = sort_last  if ember.isBlank(hash.url)
    hash.model_title = sort_last  if ember.isBlank(hash.model_title)
    hash

  get_tracker_model_name: (hash) ->
    str = (hash or {}).model_name or ''
    return 'phases'   if str.match(/\/phase/)
    return 'cases'    if str.match(/\/assignment/)
    return 'spaces'   if str.match(/\/space/)
    return ''
