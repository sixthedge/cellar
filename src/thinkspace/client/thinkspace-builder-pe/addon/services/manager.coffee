import ember          from 'ember'
import ns             from 'totem/ns'
import totem_messages from 'totem-messages/messages'
import qual_item      from 'thinkspace-builder-pe/items/qual'
import quant_item     from 'thinkspace-builder-pe/items/quant'

###
# # manager.coffee
# - Type: **Service**
# - Package: **ethinkspace-builder-pe**
###
export default ember.Service.extend
  model:       null # assessment
  quant_items: null
  qual_items:  null

  builder: ember.inject.service()

  steps: ember.computed.reads 'builder.steps'

  initialize: ->
    new ember.RSVP.Promise (resolve, reject) =>
      promises = ember.makeArray()

      steps    = @get('steps')
      promises = {}

      steps.forEach (step) =>
        id                = step.get('id')
        promises["#{id}"] = step.init_data()

      ember.RSVP.hash(promises).then (results) =>
        ## Each step's results are a key in the results hash
        for step_id, obj of results
          if ember.isPresent(obj)
            ## If there are results from a particular step, set them to the manager
            for key, value of obj
              console.log("[manager init] setting #{key} to #{value}")

              @set("#{key}", value)

        @set_model(@get('assessment'))
        @create_question_items('qual')
        @create_question_items('quant')

        resolve()

  # ### Model helpers

  ## Model is set to the assessment
  set_model: (model) -> 
    console.info "[pa:builder] Model set to: ", model
    @set 'model', model

  save_model: ->
    model = @get 'model'
    console.log('saving model ', model)
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
    console.log('[pe manager] model is ', model)
    model.get "#{type}_items"

  add_item: (type, item) ->
    items = @get_items_for_type type
    items.pushObject item
    @save_model().then =>
      @create_question_items(type)

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
    items = @get_items_for_type(type)
    console.log('[pe] manager items are ', items)
    return 1 unless ember.isPresent(items)
    sorted_items = items.sortBy('id')
    id           = sorted_items.get('lastObject.id')
    if ember.isPresent(id) then id = id + 1 else id = 1

  create_quant_items: (opts={}) ->
    assessment = @get('assessment')
    quants = assessment.get('value.quantitative') || ember.makeArray()

    items = @get('quant_items') || ember.makeArray()

    i_ids = items.mapBy('id')
    ## TODO: make sure that d_ids handles updates to questions
    d_ids = ember.makeArray()

    quants.forEach (quant) =>
      id = quant.id
      i = quants.indexOf(quant)

      if !i_ids.contains(id) || (i_ids.contains(id) && d_ids.contains(id))
        q_item = @create_quant_item(quant)
        items.pushObject(q_item)

    @set('quant_items', items)

  create_question_items: (type, opts={}) ->
    assessment = @get('assessment')
    questions  = assessment.get("value.#{type}itative") || ember.makeArray()

    console.log('calling create_question_items with type, opts ', type, opts)

    items   = @get("#{type}_items") || ember.makeArray()
    delta   = opts.delta || ember.makeArray()
    new_ids = opts.new_ids || ember.makeArray()
    i_ids   = items.mapBy('id')
    ## TODO: make sure that d_ids handles updates to questions
    d_ids   = delta.mapBy('id')

    console.log('d_ids are ', d_ids)

    questions.forEach (question) =>
      id = question.id
      i  = questions.indexOf(question)

      ## We need to create a new item if:
      ## => 1. An id that is in the assessment's value column isn't in the current set of items
      ## => 2. An id is in the delta ids (happens when an item is updated)
      if !i_ids.contains(id) || (i_ids.contains(id) && d_ids.contains(id))
        q_item = @create_question_item(type, question)
        ## If we identify an updated id, replace the existing item with a new one at the same index
        if d_ids.contains(id)
          console.log('found delta id ', id)
          cur_item = items.filter((item) -> item.get('id') == id).get('firstObject')
          index = items.indexOf(cur_item)
          items.removeAt(index)
          items.insertAt(index, q_item)
        ## Otherwise, push a new item to the back of the array
        else
          items.pushObject(q_item)

      ## Not sure why we need this, but is present in builder-rat implementation
      ## Leaving commented out until I know why (Dylan 6/13)
      q_item = items.findBy('id', id)
      items.removeObject(q_item)
      items.insertAt(i, q_item)

    q_ids = questions.mapBy('id')
    i_ids = items.mapBy('id')

    del = i_ids.filter ((id) -> !q_ids.contains(id))
    del.forEach (id) => items.removeObject(items.findBy('id', id))
      
    new_ids.forEach (id) => items.findBy('id', id).set('is_new', true)

    @set("#{type}_items", items)

  create_question_item: (type, item) ->
    if type == 'qual'
      return @create_qual_item(item)
    else if type == 'quant'
      return @create_quant_item(item)

  create_qual_item: (item) ->
    qual_item.create
      model:      item
      assessment: @get('assessment')

  create_quant_item: (item) ->
    quant_item.create
      model:      item
      assessment: @get('assessment')
