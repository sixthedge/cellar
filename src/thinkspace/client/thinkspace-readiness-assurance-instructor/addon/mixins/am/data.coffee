import ember from 'ember'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import util  from 'totem/util'
import response_manager from 'thinkspace-readiness-assurance/managers/response'

export default ember.Mixin.create

  data_values: null

  reset_data: -> @set 'data_values', {}

  get_data_value: (prop)        -> @get "data_values.#{prop}"
  set_data_value: (prop, value) -> @set "data_values.#{prop}", value

  get_model:         -> @get_data_value 'model'
  set_model: (model) ->
    @totem_scope.authable(model)
    @set_data_value 'model', model

  sort_users: (users) ->
    return [] if ember.isBlank(users)
    user.name = @get_username(user) for user in users
    users.sortBy 'name'

  # convert team-users to user-teams
  # returns: [ {user: {id:...}, teams:[{id:..}, {id:...}, ...}], ...]
  get_trat_user_teams: ->
    new ember.RSVP.Promise (resolve, reject) =>
      #users = @get_data_value('trat_user_teams')
      #return resolve(users) if ember.isPresent(users)
      users = {}
      @get_trat_team_users().then (team_users) =>
        for team_hash in (team_users or [])
          team = ember.merge {}, team_hash.team
          for team_user in (team_hash.users or [])
            user_id = team_user.id
            user    = users[user_id]
            if ember.isBlank(user)
              user       = users[user_id] = {user: ember.merge {}, team_user}
              user.teams = []
            user.teams.push(team)
        user_teams = util.hash_values(users)
        @set_data_value 'trat_user_teams', user_teams
        resolve(user_teams)

  # returns: [ {team: {id:...}, users:[{id:..}, {id:...}, ...]}, ...]
  get_trat_team_users: ->
    new ember.RSVP.Promise (resolve, reject) =>
      #team_users = @get_data_value('trat_team_users')
      #return resolve(team_users) if ember.isPresent(team_users)
      query = @get_auth_query @get_trat_url('team_users')
      ajax.object(query).then (payload) =>
        team_users = @sort_team_users(payload.teams or [])
        @set_data_value 'trat_team_users', team_users
        resolve(team_users)

  sort_team_users: (team_users) ->
    return team_users if ember.isBlank(team_users)
    team_users.sortBy('team.title')

  get_trat_assessment: ->
    new ember.RSVP.Promise (resolve, reject) =>
      #assessment = @get_data_value('trat_assessment')
      #return resolve(assessment) if ember.isPresent(assessment)
      query = @get_auth_query @get_trat_url('assessment')
      ajax.object(query).then (payload) =>
        data       = payload.data or {}
        id         = data.id
        type       = data.type
        @tc.push_payload(payload)
        assessment = @tc.peek_record(type, id)
        console.warn assessment
        @set_data_value 'trat_assessment', assessment
        resolve(assessment)

  get_irat_authable: ->
    new ember.RSVP.Promise (resolve, reject) =>
      #authable = @get_data_value('irat_authable')
      #return resolve(authable) if ember.isPresent(authable)
      @get_irat_assessment().then (assessment) =>
        assessment.get('authable').then (authable) =>
          @set_data_value 'irat_authable', authable
          resolve(authable)

  get_irat_assessment: ->
    new ember.RSVP.Promise (resolve, reject) =>
      #assessment = @get_data_value('irat_assessment')
      #return resolve(assessment) if ember.isPresent(assessment)
      query = @get_auth_query @get_irat_url('assessment')
      ajax.object(query).then (payload) =>
        data       = payload.data or {}
        id         = data.id
        type       = data.type
        @tc.push_payload(payload)
        assessment = @tc.peek_record(type, id)
        console.warn assessment
        @set_data_value 'irat_assessment', assessment
        resolve(assessment)

  load_trat_responses: ->
    new ember.RSVP.Promise (resolve, reject) =>
      #return resolve() if @get_data_value('responses_loaded') == true
      query = @get_auth_query @get_trat_url('responses')
      ajax.object(query).then (payload) =>
        @tc.push_payload(payload)
        @set_data_value 'responses_loaded', true
        resolve()

  get_trat_response_managers: ->
    new ember.RSVP.Promise (resolve, reject) =>
      #rms = @get_data_value('trat_response_managers')
      #return resolve(rms) if ember.isPresent(rms)        
      @get_trat_assessment().then (assessment) =>
        @get_trat_team_users().then (team_users) =>
          @load_trat_responses().then =>
            promises = []
            assessment.get(ns.to_p 'ra:responses').then (responses) =>
              responses.forEach (response) =>
                team_id = response.get('ownerable_id')
                data    = team_users.find (data) => data.team.id == team_id
                @error "Team [id: #{team_id}] not found in team data."  unless data
                team_id    = data.team.id
                room       = data.team.room
                title      = data.team.title
                room_users = data.users
                rm         = @get_response_manager()
                promises.push(
                  rm.init_manager
                    assessment:     assessment
                    response:       response
                    room:           room
                    room_users:     room_users
                    title:          title
                    ownerable_id:   team_id
                    ownerable_type: 'thinkspace/team/team'
                    readonly:       true
                    admin:          true
                    trat:           true
                )
              ember.RSVP.all(promises).then (rms) =>
                sorted_rms = rms.sortBy 'title'
                @set_data_value 'trat_response_managers', sorted_rms
                resolve(sorted_rms)

  get_response_manager: ->
    response_manager.create
      store:  @store
      tvo:    @tvo
      ttz:    @ttz
      pubsub: @pubsub
      se:     @se

