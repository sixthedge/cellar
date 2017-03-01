import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # templates.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend

  manager: ember.inject.service()

  select_template:        null
  confirm_template:       null
  user_template_selected: false
  selected_template:      ember.computed.reads 'assessment_template_michaelsens'

  assessment_templates:   ember.computed.reads 'step.assessment_templates'
  user_templates:         ember.computed.reads 'step.user_templates'
  is_editing_template:    ember.computed.reads 'step.is_editing_template'

  has_no_user_templates: ember.computed.empty 'user_templates'

  assessment_template_michaelsens:  ember.computed 'assessment_templates', -> @get('assessment_templates').findBy 'is_michaelsens', true
  assessment_template_categories:   ember.computed 'assessment_templates', -> @get('assessment_templates').findBy 'is_categories', true
  assessment_template_blank_canvas: ember.computed 'assessment_templates', -> @get('assessment_templates').findBy 'is_blank_canvas', true

  michaelsens_selected: ember.computed 'selected_template', -> @get('selected_template') == @get('assessment_template_michaelsens')

  categories_selected: ember.computed 'selected_template', -> @get('selected_template') == @get('assessment_template_categories')

  blank_canvas_selected: ember.computed 'selected_template', -> @get('selected_template') == @get('assessment_template_blank_canvas')

  init_base: ->
    assessment = @get('manager.model')
    assessment.get('assessment_template').then (assessment_template) =>
      if ember.isPresent assessment_template
        @set 'selected_template', assessment_template
        @set 'user_template_selected', assessment_template.get('is_user')
      else
        @set 'selected_template', @get('assessment_template_michaelsens')
      @set_all_data_loaded()


  actions:
    select_assessment_template: (template) ->
      @set 'selected_template', template
      @sendAction 'select', template
      @set 'user_template_selected', false

    select_user_template: (template) ->
      @set 'selected_template', template
      @sendAction 'select', template
      @propertyDidChange('selected_template') # The properties won't recompute without this. Why is this necessary?

    toggle_user_templates: -> 
      return if @get('has_no_user_templates')
      @send 'select_user_template', @get('user_templates.firstObject')
      @toggleProperty 'user_template_selected'

    confirm: -> @sendAction('confirm')
    cancel: ->  @sendAction('cancel')
