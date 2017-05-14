import ember          from 'ember'
import ns             from 'totem/ns'
import totem_messages from 'totem-messages/messages'

###
# # manager.coffee
# - Type: **Service**
# - Package: **ethinkspace-builder-pe**
###
export default ember.Service.extend
  model: null # assessment

  # ### Model helpers
  set_model: (model) -> 
    console.info "[pa:builder] Model set to: ", model
    @set 'model', model

  save_model: ->
    model = @get 'model'
    model.save().then =>
      totem_messages.api_success source: @, model: model, action: 'update', i18n_path: ns.to_o('tbl:assessment', 'save')
    , (error) => @error(error)

  # ### New item helpers
  get_new_quant_item: (label, type, settings={}) ->
    item = 
      id:       @get_next_quant_id()
      label:    label
      type:     type
      settings: @get_new_quant_item_settings()
    item

  get_new_quant_item_settings: ->
    settings = 
      points:
        min: @get_default_quant_points_min()
        max: @get_default_quant_points_max()
      comments:
        enabled: true
      labels:
        scale:
          min: null
          max: null

  get_default_quant_points_min: -> 1
  get_default_quant_points_max: -> 10

  get_new_qual_item: (label, type, settings={}) ->
    item = 
      id:            @get_next_qual_id()
      label:         label
      feedback_type: 'positive'
      type:          type

  # ### Add helpers
  add_quant_item: ->    
    item = @get_new_quant_item('New label', 'range')
    @add_item('quant', item)

  add_qual_item: (type='textarea') ->
    item = @get_new_qual_item('New positive qualitative question.', type)
    @add_item('qual', item)

  # ### Delete helpers
  delete_quant_item: (item) -> @delete_item('quant', item)
  delete_qual_item:  (item) -> @delete_item('qual', item)

  # ### Reorder helpers
  reorder_quant_item: (item, offset) -> @reorder_item('quant', item, offset)
  reorder_qual_item:  (item, offset) -> @reorder_item('qual', item, offset)

  # ### Duplication helpers
  duplicate_quant_item: (item) -> @duplicate_item('quant', @get_next_quant_id(), item)
  duplicate_qual_item:  (item) -> @duplicate_item('qual', @get_next_qual_id(), item)

  # ### ID helpers
  get_next_quant_id: -> @get_next_id('quant')
  get_next_qual_id:  -> @get_next_id('qual')

  # ### Shared helpers
  get_items_for_type: (type) ->
    model     = @get 'model'
    model.get "#{type}_items"

  add_item: (type, item) ->
    items = @get_items_for_type type
    items.pushObject item
    @save_model()

  delete_item: (type, item) ->
    items = @get_items_for_type type
    items.removeObject item
    @save_model()

  reorder_item: (type, item, offset) ->
    items = @get_items_for_type type
    index = items.indexOf(item)
    return unless index > -1
    switch offset
      when 1
        add_at = index + 1
      when -1
        add_at = index - 1
      when 'top'
        add_at = 0
      when 'bottom'
        add_at = items.get('length') - 1
    return if add_at < 0
    length = items.get('length')
    return if add_at > length - 1
    items.removeAt(index)
    items.insertAt(add_at, item)
    @save_model()

  duplicate_item: (type, id, item) ->
    items = @get_items_for_type type
    index = items.indexOf(item)
    return unless index > -1
    add_at = index + 1
    return if add_at < 0
    new_item    = ember.merge({}, item)
    new_item.id = id
    items.insertAt add_at, new_item

    @save_model()

  get_next_id: (type) ->
    items = @get_items_for_type(type).sortBy('id')
    id    = items.get('lastObject.id')
    if ember.isPresent(id) then id = id + 1 else id = 1