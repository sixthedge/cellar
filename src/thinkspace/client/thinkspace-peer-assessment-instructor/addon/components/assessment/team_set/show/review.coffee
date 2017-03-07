import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  # ### Initialization
  init_base: -> 
    @set 'edit_components', ember.makeArray()
    @init_reviewable()
    @set_all_data_loaded()

  init_reviewable: ->
    reviewable = @get('team_members').findBy 'id', @get('model.reviewable_id').toString()
    @set 'reviewable', reviewable

  # ### Helpers
  get_edit_component_for_id: (id) -> @get('edit_components').findBy 'model_id', id

  # ### Actions
  actions:

    register_component: (component) -> @get('edit_components').pushObject(component)
    unregister_component: (component) -> @get('edit_components').removeObject(component)

    toggle_edit: -> @toggleProperty 'is_editing'

    cancel: -> @send 'toggle_edit'

    save: ->
      @send 'toggle_edit'

      review = @get 'model'
      items  = @get('assessment.qualitative_items')

      items.forEach (item) =>
        component = @get_edit_component_for_id(item.id)
        return console.warn "No component found for item id #{item.id}" unless ember.isPresent(component)
        value = component.get('value')
        review.set_qualitative_value item.id, item.feedback_type, value
      review.save().then =>
        @totem_messages.api_success source: @, model: review, action: 'update', i18n_path: ns.to_o('peer_assessment', 'review', 'save')
