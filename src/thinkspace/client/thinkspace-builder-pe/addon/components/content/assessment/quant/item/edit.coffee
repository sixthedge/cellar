import ember             from 'ember'
import base              from 'thinkspace-base/components/base'
import changeset_helpers from 'thinkspace-common/mixins/helpers/common/changeset'

###
# # edit.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend changeset_helpers,
  # # Services
  manager:           ember.inject.service()
  builder:           ember.inject.service()

  # # Properties
  display_min: null
  display_max: null

  # # Computed properties
  changeset:         ember.computed.reads 'model.changeset'
  points_changeset:  ember.computed.reads 'model.points_changeset'
  p_min:             ember.computed.reads 'model.points_changeset.min'
  p_max:             ember.computed.reads 'model.points_changeset.max'
  label_changeset:   ember.computed.reads 'model.label_changeset'
  has_comments:      ember.computed.reads 'model.settings.comments.enabled'
  assessment:        ember.computed.reads 'manager.model'
  points_per_member: ember.computed.reads 'builder.step_content.assessment_changeset.points_per_member'

  update_model: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model      = @get('model')
      changesets = model.get_changesets()
      @determine_validity(changesets).then (validity) =>
        resolve(validity)

  # # Helpers
  # ## Points
  #
  # Note: Has to be an observer (or callback) because in order for
  # the validator to work, it needs to have the `changes` property
  # set correctly to do the comparison.  To do this, the value must be
  # set, then a validate() called on the changeset to recompute both sides
  # of the validator.
  #
  # Note2: Using an observer here to trigger changes as I could not
  # figure out a way to bind to an event when using the browser's
  # up and down arrows on a input type='number'
  p_min_changed_obs: ember.observer 'p_min', -> @p_min_changed()
  p_max_changed_obs: ember.observer 'p_max', -> @p_max_changed()
  p_min_changed: -> @p_change('min')
  p_max_changed: -> @p_change('max')
  p_change: (type) ->
    changeset = @get('model.points_changeset')
    value = @p_value_for_type(type)
    changeset.set(type, value)
    changeset.validate()
  p_value_for_type: (type) ->
    value = @get('p_min') if type == 'min'
    value = @get('p_max') if type == 'max'
    parseInt(value)

  actions:
    toggle_has_comments: -> @toggleProperty 'has_comments'
    edit:                -> @sendAction('edit', false)
    update:              -> @update_model().then (valid) => @sendAction('update') if valid
    duplicate:           -> @sendAction('duplicate')
    delete:              -> @sendAction('delete')
