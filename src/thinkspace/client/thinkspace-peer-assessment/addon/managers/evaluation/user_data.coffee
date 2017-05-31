import ember       from 'ember'
import totem_scope from 'totem/scope'
import tc          from 'totem/cache'
import ta          from 'totem/ds/associations'
import tm          from 'totem-messages/messages'

###
# # user_data.coffee
- Type: **Mixin*
- Package: **thinkspace-peer-assessment**
# Used to initially set the data for the evaluation manager.
###
export default ember.Mixin.create
  # ## Helpers
  set_user_data: ->
    @set_team().then => 
      @set_reviewables().then => 
        @set_review_set().then => 
          @set_reviews().then => 
            @set_reviewable_from_settings().then => 
              @set_review()

  set_team: ->
    new ember.RSVP.Promise (resolve, reject) =>
      query   = @get_sub_action_query_params('teams')
      options = @get_sub_action_query_options('teams', ta.to_p('team'))
      @tc.query_action(ta.to_p('tbl:assessment'), query, options).then (teams) =>
        team = teams.get('firstObject')
        @debug "Team: ", team
        @set 'team', team
        has_team_members = if team.get('users.length') > 1 then true else false
        @set 'has_team_members', has_team_members
        resolve()
      , (error) => 
        @set 'has_team_members', false
        reject() # Send back up to the assessment component so it can set it there, too.
    , (error) => @error(error)

  set_reviewables: ->
    new ember.RSVP.Promise (resolve, reject) =>
      team = @get 'team'
      team.get(ta.to_p('users')).then (reviewables) =>
        ownerable   = @totem_scope.get_ownerable_record()
        reviewables = reviewables.without(ownerable)
        @debug "Reviewables: ", reviewables
        @set 'reviewables', reviewables
        resolve()
      , (error) => @error(error)
    , (error) => @error(error)

  set_review_set: ->
    new ember.RSVP.Promise (resolve, reject) =>
      query         = @get_sub_action_query_params('review_sets')
      query.team_id = @get 'team.id'
      options       = @get_sub_action_query_options('review_sets', ta.to_p('tbl:review_set'))
      @tc.query_action(ta.to_p('tbl:assessment'), query, options).then (review_sets) =>
        review_set = review_sets.get('firstObject')
        @debug "Review set: ", review_set
        @set 'review_set', review_set
        resolve()
      , (error) => @error(error)
    , (error) => @error(error)

  set_reviews: ->
    new ember.RSVP.Promise (resolve, reject) =>
      review_set = @get 'review_set'
      review_set.get(ta.to_p('tbl:reviews')).then (reviews) =>
        @debug "Reviews: ", reviews
        @set 'reviews', reviews
        resolve()
      , (error) => 
        @error(error)
    , (error) => @error(error)

  set_reviewable_from_settings: ->
    new ember.RSVP.Promise (resolve, reject) =>
      phase_settings = @get('phase_settings') or {}
      @debug "Phase settings: ", phase_settings
      reviewable_id = phase_settings.reviewable_id
      reviewable    = null
      switch
        when reviewable_id == 'confirmation'
          reviewable = reviewable_id
        when ember.isPresent(reviewable_id)
          # reviewable_id is a string, but ember-data ids are strings so findBy works.
          reviewable = @get('reviewables').findBy('id', reviewable_id)
        else
          reviewable = @get('reviewables.firstObject')

      @debug "Reviewable found as: ", reviewable
      @set 'reviewable', reviewable
      resolve()
    , (error) => @error(error)

  set_review: ->
    new ember.RSVP.Promise (resolve, reject) =>
      reviewable = @get 'reviewable'
      return resolve() if ember.isEqual(reviewable, 'confirmation')
      review = @get_review_for_reviewable(reviewable)
      @debug "Setting review: ", review
      @set 'review', review
      resolve()
    , (error) => @error(error)

  set_reviewable_phase_settings: ->
    reviewable = @get 'reviewable'
    id = if typeof reviewable == 'string' then reviewable else reviewable.get('id')
    settings = 
      reviewable_id: id
    controller = @get('thinkspace').get_phases_show_controller()
    controller.set_phase_settings settings

  get_sub_action_query: (sub_action, options={}) ->
    model      = @get 'model'
    query      = @totem_scope.get_view_query(model, sub_action: sub_action)
    query.verb = 'GET'
    query.id   = model.get 'id'
    @totem_scope.add_authable_to_query(query)
    query

  get_sub_action_query_params: (sub_action) ->
    model = @get('model')
    query = @totem_scope.get_view_query(model, sub_action: sub_action)['data']
    query.id = query.id || @get('model.id')
    query

  get_sub_action_query_options: (sub_action, model_type) ->
    model         = @get('model')
    options       = @totem_scope.get_view_query(model, sub_action: sub_action)
    options.verb  = 'GET'
    options.model = model_type
    @totem_scope.add_authable_to_query(options)
    options

