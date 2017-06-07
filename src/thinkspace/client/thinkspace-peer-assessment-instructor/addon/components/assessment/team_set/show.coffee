import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

###
# # show.coffee
- Type: **Component**
- Package: **thinkspace-peer-assessment-instructor**
###
export default base_component.extend
  # ## Properties
  # ### Computed
  anchor_review_set_id: ember.computed.reads 'anchor_review_set.id'

  # ## Events
  init_base: ->
    @init_team_set().then =>
      @init_team().then =>
        @init_review_sets().then =>
          @init_ignored_ownerables()
          @set_all_data_loaded()
          ember.run.scheduleOnce 'afterRender', => @scroll_to_anchor()

  # ## Helpers
  init_team_set: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @tc.find_record(ns.to_p('tbl:team_set'), @get('team_set_data.id')).then (team_set) =>
        @set 'model', team_set
        resolve()

  init_team: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get('model')
      model.get('team').then (team) =>
        @set 'team', team
        @set 'team_members', team.get('users')
        resolve()

  init_review_sets: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get('model')
      model.get(ns.to_p('tbl:review_sets')).then (review_sets) =>
        @set 'review_sets', @sort_review_sets(review_sets)
        resolve()

  init_ignored_ownerables: ->
    review_sets = @get('review_sets').filterBy 'is_not_complete'
    ownerable_ids = review_sets.mapBy 'ownerable_id'
    ignored_ownerables = @get('team_members').filter (ownerable) => ownerable_ids.contains(parseInt(ownerable.get('id')))
    @set 'ignored_ownerables', ignored_ownerables

  get_ownerable_for_review_set: (review_set) ->
    @get('team_members').findBy 'id', review_set.get('ownerable_id').toString()

  sort_review_sets: (review_sets) ->
    review_sets.toArray().sort (a, b) =>
      a_ownerable = @get_ownerable_for_review_set(a)
      b_ownerable = @get_ownerable_for_review_set(b)
      return 1 if a_ownerable.get('first_name') > b_ownerable.get('first_name')
      return -1 if a_ownerable.get('first_name') < b_ownerable.get('first_name')
      return a_ownerable.get('last_name') > b_ownerable.get('last_name')

  state_change: (state) ->

    model = @get 'model'

    query = 
      id:     model.get('id')
    options =
      action: state
      verb:   'PUT'

    @tc.query_action(ns.to_p('tbl:team_set'), query, options).then (review_set) => 
      @totem_messages.api_success source: @, model: model, action: state, i18n_path: ns.to_o('tbl:team_set', state)
      @update_progress_report(review_set)
    , (error) =>
          @totem_messages.api_failure error, source: @, model: model

  update_progress_report: (review_set) ->
    progress_report = @get_progress_report()
    team_set        = @get 'model'
    progress_report.process_review_sets(team_set, review_set)

  get_progress_report: -> @get 'progress_report'

  scroll_to_anchor: (anchor_review_set_id=null) ->
    anchor_review_set_id = @get('anchor_review_set_id') unless ember.isPresent(anchor_review_set_id)
    return unless ember.isPresent(anchor_review_set_id)
    name           = "review-set-#{anchor_review_set_id}"
    $anchor        = @$("div[name=#{name}]")
    top_bar_offset = 60
    scroll_time    = 500
    $('html, body').animate({scrollTop: $anchor.offset().top - top_bar_offset}, scroll_time)


  # ## Actions
  actions:
    toggle_approve: -> if @get('model.is_approved') then @state_change('unapprove') else @state_change('approve')

    select_team_set: -> @sendAction 'select_team_set', null

    scroll_to_review_set: (id) -> @scroll_to_anchor(id)