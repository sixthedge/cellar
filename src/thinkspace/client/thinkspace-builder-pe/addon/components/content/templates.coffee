import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # templates.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend
  # # Services
  manager: ember.inject.service()

  # # Properties
  select_template:        null
  confirm_template:       null
  user_template_selected: false

  # # Computed properties
  selected_template:      ember.computed.reads 'assessment_template_michaelsens'
  assessment_templates:   ember.computed.reads 'step.assessment_templates'
  user_templates:         ember.computed.reads 'step.user_templates'
  is_editing_template:    ember.computed.reads 'step.is_editing_template'
  has_no_user_templates:  ember.computed.empty 'user_templates'

  assessment_template_michaelsens:    ember.computed 'assessment_templates', -> @get('assessment_templates').findBy('is_balance', true)
  assessment_template_categories:     ember.computed 'assessment_templates', -> @get('assessment_templates').findBy('is_categories', true)
  assessment_template_blank_canvas:   ember.computed 'assessment_templates', -> @get('assessment_templates').findBy('is_blank', true)
  assessment_template_user_templates: {title: 'Use one of my saved templates', description: "Select a template you've saved."}

  is_michaelsens_selected:    ember.computed  'selected_template', -> @get('selected_template') == @get('assessment_template_michaelsens')
  is_categories_selected:     ember.computed  'selected_template', -> @get('selected_template') == @get('assessment_template_categories')
  is_blank_canvas_selected:   ember.computed  'selected_template', -> @get('selected_template') == @get('assessment_template_blank_canvas')
  is_user_templates_selected: ember.computed  'selected_template', -> @get('selected_template') == @get('assessment_template_user_templates')

  # ## Radio options  
  template_options: ember.computed 'assessment_template_michaelsens', 'assessment_template_categories', 'assessment_template_blank_canvas', ->
    michaelsens = @get('assessment_template_michaelsens')
    categories  = @get('assessment_template_categories')
    blank       = @get('assessment_template_blank_canvas')
    user        = @get('assessment_template_user_templates')
    group:
      label: 'Choose a template for your Peer Evaluation'
      summary: 'This will help you get started.  You can always save a peer evaluation as a template to use in the future.'
    choices: [
      {label: michaelsens.get('title'), value: michaelsens, summary: michaelsens.get('description')},
      {label: categories.get('title'),  value: categories,  summary: categories.get('description')},
      {label: blank.get('title'),       value: blank,       summary: blank.get('description')},
      {label: user.title,               value: user,        summary: user.description}
    ]

  # # Events
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

    confirm: -> @sendAction('confirm')
    cancel: ->  @sendAction('cancel')
