import ember       from 'ember'
import base        from 'thinkspace-base/components/base'
import ns          from 'totem/ns'
import totem_scope from 'totem/scope'
import totem_changeset from 'totem/changeset'
import v_arr_contains     from 'thinkspace-builder-pe/validators/array_contains'
import util from 'totem/util'

###
# # modified_template.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend

  model:     null ## Assessment
  step:      null
  errors:    null
  is_adding: false

  assessment_templates: ember.computed.reads 'step.user_templates'

  template_title_map: ember.computed 'assessment_templates.length', ->
    assessment_templates = @get('assessment_templates')
    assessment_templates.mapBy('title')

  init_base: ->
    @create_template()
    @get_default_title()
    @create_changeset()
    @set('errors', ember.makeArray())

  create_template: -> @set('template', totem_scope.get_store().createRecord(ns.to_p('assessment_template')))

  create_changeset: ->
    template           = @get('template')
    vpresence          = totem_changeset.vpresence(true)
    template_title_map = @get('template_title_map')

    varr = v_arr_contains({arr: template_title_map, message: 'Your new template shares a name with another template'})

    changeset = totem_changeset.create template,
      title: [vpresence, varr]
    
    @set('changeset', changeset)

  get_default_title: -> @get('template').set('title', "New Template #{moment(new Date()).format()}")

  actions:
    save_template: ->
      ## Create a new assessment template
      ## Pass the assessment template to the step's confirm_template function

      changeset            = @get('changeset')
      template             = @get('template')
      assessment           = @get('model')
      assessment_changeset = @get('step.assessment_changeset')

      changeset.validate().then =>
        #assessment_changeset.validate().then =>
        if changeset.get('isValid')
          template.set('value',          assessment.get('value'))
          template.set('ownerable_id',   totem_scope.get_current_user_id())
          template.set('ownerable_type', 'Thinkspace::Common::User')
          util.set_path_value(template, 'value.options.points.per_member', assessment_changeset.get('points_per_member')) if assessment.get('is_balance')
          ## Calling confirm template on the step will cause the assessment changeset to be updated and persisted
          changeset.save().then (saved_template) =>
            #assessment_changeset.save().then =>
            @get('step').confirm_template(saved_template)
            @get('assessment_templates').pushObject(saved_template)

    toggle_is_adding: -> @toggleProperty('is_adding')