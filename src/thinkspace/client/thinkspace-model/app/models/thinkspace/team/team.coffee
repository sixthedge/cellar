import ember from 'ember'
import ta    from 'totem/ds/associations'
import util  from 'totem/util'

export default ta.Model.extend ta.add(
    ta.polymorphic 'authable'
    ta.belongs_to 'team_category', reads: {}
    ta.belongs_to 'team_set', reads: {}
    ta.has_many   'team_users', reads: {}
    ta.has_many   'team_teamables'
    ta.has_many   'team_viewers'
    ta.has_many   'users', reads: { sort: 'sort_name:asc' }
  ),

  title:         ta.attr('string')
  description:   ta.attr('string')
  color:         ta.attr('string')
  is_member:     ta.attr('boolean')
  authable_type: ta.attr('string')
  authable_id:   ta.attr('number')
  state:         ta.attr('string')
  updates:       ta.attr()

  full_name: ember.computed.reads 'title'

  is_locked: ember.computed.equal 'state', 'locked'

  # Services
  team_manager: ember.inject.service()

  # didLoad: ->
  #   @get('team_set').then (team_set) =>
  #     return unless ember.isPresent(team_set)
  #     team_set.get('teams').then (teams) => teams.pushObject(@) unless teams.contains(@)

  # didCreate: -> @didLoad()

  reset_all: -> @reset_updates()
  reset_updates: -> @set 'updates', {}

  add_user: (user) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @change_users([user], 'add')
      @save().then =>
        @reset_updates()
        @get('team_manager').update_unassigned_users()
        resolve()

  remove_user: (user) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @change_users([user], 'remove')
      @save().then =>
        @reset_updates()
        @get('team_manager').update_unassigned_users()
        resolve()

  add_users: (users, save=false) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @change_users(users, 'add')
      return resolve() unless save
      @save().then =>
        @reset_updates()
        @get('team_manager').update_unassigned_users()
        resolve()

  remove_users: (users, save=false) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @change_users(users, 'remove')
      return resolve() unless save
      @save().then =>
        @reset_updates()
        @get('team_manager').update_unassigned_users()
        resolve()

  unload_team_users: (user_ids) ->
    new ember.RSVP.Promise (resolve, reject) =>
      records = @tc.filter ta.to_p('team_user'), (team_user) =>
        team_id = team_user.get('team_id')
        user_id = team_user.get('user_id')
        return false unless team_id == parseInt @get('id')
        user_ids.contains(user_id)
      records.then (records) =>
        records.forEach (record) => @tc.unload_record(record)
        resolve()

  change_users: (users, type) ->
    sub_key              = "users.#{type}"
    key                  = "updates.#{sub_key}"
    ids                  = util.string_array_to_numbers users.mapBy('id')
    updates              = {}
    updates.users        = @get('updates.users') || {}
    updates.users.add    = @get('updates.users.add') || []
    updates.users.remove = @get('updates.users.remove') || []
    switch type
      when 'remove'
        ids.forEach (id) => updates.users.remove.pushObject(id) unless updates.users.remove.contains(id)
      when 'add'
        ids.forEach (id) => updates.users.add.pushObject(id) unless updates.users.add.contains(id)
    @set 'updates', updates
