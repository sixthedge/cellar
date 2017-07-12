import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

###
# # review_set.coffee
- Type: **Component**
- Package: **thinkspace-peer-assessment-instructor**
###
export default base_component.extend
  # ## Properties
  # ### View Properties
  attributeBindings: ['anchor_name:name']

  # ### Internal Properties
  is_expanded: true

  # ### Computed Properties
  reviews_sort_by: ['reviewable.sort_name:asc']
  sorted_reviews:  ember.computed.sort 'model.reviews', 'reviews_sort_by'
  anchor_name:     ember.computed 'model.id', -> "review-set-#{@get('model.id')}"

  # ## Events
  init_base: -> 
    @init_ownerable()
    @set_all_data_loaded()

  # ## Helpers
  init_ownerable: ->
    ownerable = @get('team_members').findBy 'id', @get('model.ownerable_id').toString()
    @set 'ownerable', ownerable

  # ### Helpers
  review_set_action: (action) ->
    model = @get 'model'

    query = 
      id:     model.id
    options =
      action: action
      verb:   'PUT'

    @tc.query_action(ns.to_p('tbl:review_set'), query, options).then (review_set) =>
      @totem_messages.api_success source: @, model: model, action: action, i18n_path: ns.to_o('tbl:review_set', action)
    , (error) =>
      @totem_messages.api_failure error, source: @, model: model, action: saction    

  # ## Actions
  actions:
    unlock: -> @review_set_action('unlock')
    ignore: -> @review_set_action('ignore')
    unignore: -> @review_set_action('unignore')
    complete: -> @review_set_action('complete')
    remind: -> @review_set_action('remind')

    toggle_expand: -> @toggleProperty 'is_expanded'