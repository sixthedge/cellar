import ember from 'ember'
import util  from 'totem/util'
import totem_changeset from 'totem/changeset'

###
# # qual.coffee
# - Type: **Object**
# - Package: **ethinkspace-builder-pe**
###
export default ember.Object.extend
  # ### Properties
  model:         null
  
  # ### Computed properties
  is_textarea: ember.computed.equal 'changeset.type', 'textarea'
  is_text:     ember.computed.equal 'changeset.type', 'text'

  id:          ember.computed.reads 'model.id'

  init: ->
    @_super()
    @create_changeset()

  create_changeset: ->
    model = @get('model')
    vlength = totem_changeset.vlength(min: 4)

    changeset = totem_changeset.create(model,
      label: [vlength]
    )

    changeset.set('show_errors', true)

    @set('changeset', changeset)
  
  ######
  ## LEGACY
  ######
  
  # ### Setters
  # set_value: (property, value) ->
  #   fn = "set_#{property}"
  #   return unless @[fn]?
  #   @[fn](value)

  # set_id:            (id) ->     util.set_path_value @, 'model.id', parseInt(id)
  # set_label:         (label) ->  util.set_path_value @, 'model.label', label
  # set_type:          (type) ->   util.set_path_value @, 'model.type', type
  # set_feedback_type: (type) ->   util.set_path_value @, 'model.feedback_type', type
