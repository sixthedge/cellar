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

  assessment_templates: ember.computed.reads 'manager.assessment_templates'
  user_templates:       ember.computed.reads 'manager.user_templates'
  assessment:           ember.computed.reads 'manager.assessment'
  
  is_preview:           ember.computed.reads 'assessment.has_no_assessment_template'
  is_editing_template:  false

  is_readonly:          ember.computed.or 'is_preview', 'is_editing_template'

  has_qual_items:  ember.computed.notEmpty 'manager.qual_items'
  has_quant_items: ember.computed.notEmpty 'manager.quant_items'

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
    @create_changesets()
    @init_template()

  init_data: ->
    new ember.RSVP.Promise (resolve, reject) =>
      promises =
        assessment_templates: @query_assessment_templates()
        user_templates:       @query_user_templates()
        assessment:           @query_assessment()

      ember.RSVP.hash(promises).then (results) =>
        resolve(results)

  validate: ->
    new ember.RSVP.Promise (resolve, reject) =>
      ## Only changeset we need to validate.
      assessment_changeset = @get('assessment_changeset')
      assessment_changeset.validate().then =>
        resolve(assessment_changeset.get('isValid'))

  update_model: -> 
    manager = @get('manager')
    console.log('calling step update_model with manager ', manager)
    manager.save_model()

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
    manager   = @get('manager')
    changeset = @get('assessment_changeset')
    template  = @get('template') unless ember.isPresent(template)
    changeset.set ns.to_p('assessment_template'), template
    changeset.set 'value', template.get('value')
    changeset.execute()
    manager.confirm_template().then =>
      @set('template', template)
      @reset_is_preview()
      @reset_is_editing_template()

  reset_is_preview: -> @set 'is_preview', false
  set_is_preview: ->   @set 'is_preview', true

  set_is_editing_template:   -> @set('is_editing_template', true)
  reset_is_editing_template: -> @set('is_editing_template', false)

  add_item_with_type: (type) ->
    manager = @get('manager')
    console.log('calling add_item_with_type ', type, @get('loading'))

    @set_loading("#{type}")
    manager.add_item_with_type(type).then =>
      @reset_loading("#{type}")

  duplicate_item: (type, id, item) ->
    manager = @get('manager')
    @set_loading("#{type}")
    manager.duplicate_item(type, id).then =>
      @reset_loading("#{type}")

  reorder_item: (type, item, offset) ->
    manager = @get('manager')
    @set_loading("#{type}")
    manager.reorder_item(type, item, offset).then =>
      manager.create_question_items(type)
      @reset_loading("#{type}")
    , (error) =>
      @reset_loading("#{type}")

  template:          ember.computed.reads 'assessment_templates.firstObject'