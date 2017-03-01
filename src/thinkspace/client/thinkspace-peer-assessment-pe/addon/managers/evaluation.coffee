import ember       from 'ember'
import totem_scope from 'totem/scope'
import tc          from 'totem/cache'
import ta          from 'totem/ds/associations'
import tm          from 'totem-messages/messages'
import totem_changeset from 'totem/changeset'

# ### Parts
import reviews     from 'thinkspace-peer-assessment-pe/managers/evaluation/reviews'
import user_data   from 'thinkspace-peer-assessment-pe/managers/evaluation/user_data'
import balance     from 'thinkspace-peer-assessment-pe/managers/evaluation/balance'
import qualitative from 'thinkspace-peer-assessment-pe/managers/evaluation/qualitative'

export default ember.Object.extend reviews, user_data, balance, qualitative,
  # ### Services
  thinkspace: ember.inject.service()

  # ### Properties
  component: null # PhaseComponent that is rendered
  model:     null # peer_assessment/assessment model

  team:             null
  has_team_members: null
  reviewables:      null
  review_set:       null
  reviews:          null
  reviewable:       null
  review:           null

  # ### Computed properties
  is_confirmation:     ember.computed.equal 'reviewable', 'confirmation'
  is_read_only:        ember.computed.or 'totem_scope.is_read_only', 'review_set.is_read_only'
  is_review_read_only: ember.computed.or 'review.is_not_approvable'
  is_disabled:         ember.computed.or 'has_errors', 'is_read_only' # Also accounts for errors.
  has_errors:          ember.computed.equal 'changeset.isValid', false

  confirmation_obs: ember.observer 'is_confirmation', -> @validate()

  # #### Misc computed properties
  phase_settings: ember.computed -> @get('thinkspace').get_phase_settings()

  # ### Observers
  reviewable_observer: ember.observer 'reviewable', ->
    reviewable = @get 'reviewable'
    @set_reviewable_phase_settings() if ember.isPresent(reviewable)

  # ### Events
  init: ->
    @_super()
    @totem_scope    = totem_scope
    @tc             = tc
    @totem_messages = tm
    @is_debug       = true
    @create_changeset()

  create_changeset: ->
    validations = @init_validations()
    changeset   = totem_changeset.create(@, validations)
    @set_changeset(changeset)

  set_changeset: (cs) -> @set('changeset', cs)
  get_changeset: -> @get('changeset')

  init_validations: ->
    model = @get('model') ## Assessment

    validations        = {}
    vqual_present      = totem_changeset.vpresence({presence: true, message: 'You must respond to all qualitative sections.'})

    validations.valid_qual_sections = vqual_present

    return validations unless model.get('is_balance')

    vpoints_diff       = totem_changeset.vnumber({gte: 2, message: 'Not all evaluations can have the same score.'})
    vpoints_remain_gte = totem_changeset.vnumber({gte: 0, message: 'You cannot have negative points.'})
    vpoints_remain_lte = totem_changeset.vnumber({lte: 0, message: 'You must spend all of your points.'})
    
    validations.points_different = vpoints_diff
    validations.points_remaining = [vpoints_remain_gte, vpoints_remain_lte]

    return validations

  # ### Submission
  submit: ->
    @validate().then (valid) =>
      return unless valid
      review_set = @get 'review_set'
      @debug "Submitting review set: ", review_set
      query = 
        id:     review_set.get('id')
        
      options = 
        action: 'submit'
        verb:   'PUT'

      @totem_messages.show_loading_outlet()
      @tc.query_action(ta.to_p('tbl:review_set'), query, options).then =>
        @totem_messages.hide_loading_outlet()
        @totem_messages.api_success source: @, model: review_set, action: 'submit', i18n_path: ta.to_o('tbl:review_set', 'submit')
        @get('thinkspace').transition_to_current_assignment()

  validate: ->
    new ember.RSVP.Promise (resolve, reject) =>
      changeset = @get('changeset')
      changeset.validate().then =>
        resolve(changeset.get('isValid'))

  # ### Helpers
  debug: (message, args...) ->
    console.log "[tbl:evaluation_manager] #{message}", args if @is_debug