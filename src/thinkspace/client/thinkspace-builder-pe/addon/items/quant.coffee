import ember             from 'ember'
import util              from 'totem/util'
import totem_changeset   from 'totem/changeset'
import vcomparison      from 'thinkspace-builder-pe/validators/comparison'
import changeset_helpers from 'thinkspace-common/mixins/helpers/common/changeset'

###
# # quant.coffee
# - Type: **Object**
# - Package: **ethinkspace-builder-pe**
###
export default ember.Object.extend changeset_helpers,
  
  manager: ember.inject.service()

  # ### Properties
  model:     null
  slider_step:  1
  slider_value: 3

  is_selected: false

  # ### Computed properties

  points_descriptive_enabled: ember.computed 'assessment.points_descriptive_enabled', 'model.settings.labels.scale.min', 'model.settings.labels.scale.max', ->
    (@get('points_descriptive_low') and @get('points_descriptive_high')) or @get('assessment.points_descriptive_enabled')

  has_comments: ember.computed 'settings.comments.enabled', -> @get 'settings.comments.enabled'

  id:         ember.computed.reads 'model.id'
  label:      ember.computed.reads 'model.label'
  type:       ember.computed.reads 'model.type'
  settings:   ember.computed.reads 'model.settings'
  assessment: ember.computed.reads 'manager.model'

  init: ->
    @_super()
    @create_changeset()

  create_changeset: ->
    model = @get('model')

    vpresence =   totem_changeset.vpresence(true)

    changeset = totem_changeset.create(model,
      label: [vpresence]
    )

    points_changeset = totem_changeset.create(model.settings.points,
      min: [vcomparison({compare_to: 'max', type: 'lt', message: 'Minimum must be smaller than maximum'})],
      max: [vcomparison({compare_to: 'min', type: 'gt', message: 'Maximum must be greater than minimum'})]
    )
    
    label_changeset  = totem_changeset.create(model.settings.labels.scale)

    changeset.set('show_errors', true)
    points_changeset.set('show_errors', true)
    label_changeset.set('show_errors', true)

    @set('changeset', changeset)
    @set('points_changeset', points_changeset)
    @set('label_changeset', label_changeset)

  changeset_rollback: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @changesets_rollback(@get_changesets()).then =>
        resolve()

  changeset_persist: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @changesets_save(@get_changesets()).then =>
        resolve()

  get_changesets: ->
    changeset        = @get('changeset')
    label_changeset  = @get('label_changeset')
    points_changeset = @get('points_changeset')
    changesets       = [changeset, label_changeset, points_changeset]

  get_model_property: (path) ->
    model = @get 'model'
    model = ember.Object.create(model)
    model.get(path)
