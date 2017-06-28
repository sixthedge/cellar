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

  selected_radio: null

  # # Computed properties
  selected_template:      ember.computed.reads 'assessment_template_michaelsens'
  assessment_templates:   ember.computed.reads 'step.assessment_templates'
  user_templates:         ember.computed.reads 'step.user_templates'
  is_editing_template:    ember.computed.reads 'step.is_editing_template'
  has_no_user_templates:  ember.computed.empty 'user_templates'

  assessment_template_michaelsens:    ember.computed 'assessment_templates', -> @get('assessment_templates').findBy('is_balance', true)
  assessment_template_categories:     ember.computed 'assessment_templates', -> @get('assessment_templates').findBy('is_categories', true)
  assessment_template_blank_canvas:   ember.computed 'assessment_templates', -> @get('assessment_templates').findBy('is_blank', true)
  assessment_template_user_templates: {id: 'user_templates', title: 'Use one of my saved templates', description: "Select a template you've saved."}

  is_michaelsens_selected:    ember.computed  'selected_radio', -> @get('selected_radio') == @get('assessment_template_michaelsens')
  is_categories_selected:     ember.computed  'selected_radio', -> @get('selected_radio') == @get('assessment_template_categories')
  is_blank_canvas_selected:   ember.computed  'selected_radio', -> @get('selected_radio') == @get('assessment_template_blank_canvas')
  is_user_templates_selected: ember.computed  'selected_radio', -> @get('selected_radio') == @get('assessment_template_user_templates')

  # ## Radio options  
  template_options: ember.computed 'assessment_template_michaelsens', 'assessment_template_categories', 'assessment_template_blank_canvas', ->
    michaelsens = @get('assessment_template_michaelsens')
    categories  = @get('assessment_template_categories')
    blank       = @get('assessment_template_blank_canvas')
    user        = @get('assessment_template_user_templates')
    group:
      label: 'Choose a template for your Peer Evaluation'
      summary: 'These templates will help you get started.  You can always save a peer evaluation as a template to use in the future.'
    choices: [
      {label: michaelsens.get('title'), value: michaelsens, summary: michaelsens.get('description')},
      {label: categories.get('title'),  value: categories,  summary: categories.get('description')},
      {label: blank.get('title'),       value: blank,       summary: blank.get('description')},
      {label: user.title,               value: user,        summary: user.description}
    ]

  get_system_templates: ->
    michaelsens = @get('assessment_template_michaelsens')
    categories  = @get('assessment_template_categories')
    blank       = @get('assessment_template_blank_canvas')
    templates   = [michaelsens, categories, blank]
    templates

  # # Events
  init_base: ->
    assessment = @get('manager.model')
    @set_loading('all')
    assessment.get('assessment_template').then (assessment_template) =>
      if ember.isPresent assessment_template
        if assessment_template.get('is_user')
          @set('selected_radio', @get('assessment_template_user_templates'))
          @set 'user_template_selected', assessment_template.get('is_user')
        else
          sys_templates = @get_system_templates()
          @set('selected_radio', sys_templates.findBy('id', assessment_template.get('id')))
        @set 'selected_template', assessment_template
      else
        @send 'select_radio', @get('assessment_template_michaelsens')

      @reset_loading('all')

  actions:
    select_assessment_template: (template) ->
      @set('selected_template', template)
      @sendAction 'select', template

    select_radio: (radio) ->
      @set('selected_radio', radio)
      radio = @get('user_templates.firstObject') if radio.id == 'user_templates' && ember.isPresent(@get('user_templates'))
      @send('select_assessment_template', radio)

    confirm: -> @sendAction('confirm')
    cancel: ->  @sendAction('cancel')
