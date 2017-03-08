import ember           from 'ember'
import ns              from 'totem/ns'
import tc              from 'totem/cache'
import totem_changeset from 'totem/changeset'
import ta              from 'totem/ds/associations'
import totem_scope     from 'totem/scope'
import step            from './step'

###
# # content.coffee
- Type: **Step Object**
- Package: **ethinkspace-builder-pe**
###
export default step.extend

  id: 'content'
  index: 1
  route_path: 'content'

  builder: ember.inject.service()
  manager: ember.inject.service()

  is_preview:          ember.computed.reads 'assessment.has_no_assessment_template'
  is_editing_template: false

  is_readonly: ember.computed.or 'is_preview', 'is_editing_template'

  ## API Methods

  create_changesets: ->
    model         = @get('model')
    changeset     = totem_changeset.create(model)

    @set('changeset', changeset)

    assessment  = @get('assessment')
    validations = @init_validations()

    assessment_cs = totem_changeset.create(assessment, validations)
    @set 'assessment_changeset', assessment_cs

  init_validations: ->
    assessment = @get('assessment')

    validations = {}

    if assessment.get('is_balance')
      vpresence = totem_changeset.vpresence({presence: true, message: 'Points per member must be present for an evaluation using balance points'})
      validations.points_per_member = [vpresence]

    validations

  initialize: ->
    @reset_all_data_loaded()
    model = @get('builder.model')
    @set 'model', model

    promises = 
      assessment_templates: @query_assessment_templates()
      user_templates:       @query_user_templates()
      assessment:           @query_assessment()

    @rsvp_hash_with_set(promises, @).then (results) =>
      @create_changesets()
      @set_manager_model()
      @init_template().then =>
        @set_all_data_loaded()

  validate: ->
    new ember.RSVP.Promise (resolve, reject) =>
      ## Only changeset we need to validate.
      assessment_changeset = @get('assessment_changeset')
      assessment_changeset.validate().then =>
        resolve(assessment_changeset.get('isValid'))

  set_manager_model: ->
    ## Used to initialize the manager service's 'model' property to an assessment if present.
    manager    = @get('manager')
    assessment = @get('assessment')

    manager.set_model(assessment) if ember.isPresent(assessment)

  init_template: ->
    new ember.RSVP.Promise (resolve, reject) =>
      assessment = @get('assessment')

      assessment.get('assessment_template').then (template) =>
        template = @get('assessment_templates.firstObject') unless ember.isPresent(template)
        @set('template', template)
        resolve()

  query_assessment_templates: ->
    new ember.RSVP.Promise (resolve, reject) =>
      tc.query(ta.to_p('assessment_template'), {}).then (assessment_templates) =>
        resolve assessment_templates
      , (error) => reject error

  query_user_templates: ->
    new ember.RSVP.Promise (resolve, reject) =>
      query =
        user_id: totem_scope.get_current_user_id()
      options =
        action: 'user_templates'
      tc.query_action(ta.to_p('assessment_template'), query, options).then (user_templates) =>
        resolve user_templates
      , (error) => reject error

  query_assessment: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get('model')
      query =
        id:                 model.get('id')
        componentable_type: ns.to_p('tbl:assessment')
      options =
        action:             'phase_componentables'
        model:              ns.to_p('tbl:assessment')

      tc.query_action(ns.to_p('assignment'), query, options).then (assessments) =>
        resolve assessments.get('firstObject')
      , (error) => reject error

  select_template: (template) -> @set('template', template) if ember.isPresent(template)
  
  confirm_template: (template=null) -> 
    changeset = @get('assessment_changeset')
    template  = @get('template') unless ember.isPresent(template)
    changeset.set ns.to_p('assessment_template'), template
    changeset.set 'value', template.get('value')
    changeset.save().then =>
      @set('template', template)
      @reset_is_preview()
      @reset_is_editing_template()

  reset_is_preview: -> @set 'is_preview', false
  set_is_preview: -> @set 'is_preview', true

  set_is_editing_template:   -> @set('is_editing_template', true)
  reset_is_editing_template: -> @set('is_editing_template', false)

  template:          ember.computed.reads 'assessment_templates.firstObject'