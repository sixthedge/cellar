import ember             from 'ember'
import totem_changeset   from 'totem/changeset'
import changeset_helpers from 'thinkspace-common/mixins/helpers/common/changeset'
###
# # qual.coffee
# - Type: **Object**
# - Package: **ethinkspace-builder-pe**
###
export default ember.Object.extend changeset_helpers,
  # ### Properties
  model:         null
  
  # ### Computed properties
  is_textarea:   ember.computed.equal 'type', 'textarea'
  is_text:       ember.computed.equal 'type', 'text'

  id:            ember.computed.reads 'model.id'
  label:         ember.computed.reads 'model.label'
  feedback_type: ember.computed.reads 'model.feedback_type'

  init: ->
    @_super()
    @create_changeset()

  create_changeset: ->
    model   = @get('model')
    vlength = totem_changeset.vlength(min: 4)

    changeset = totem_changeset.create model,
      label: [vlength]
    
    changeset.set('show_errors', true)

    @set('changeset', changeset)

  changeset_rollback: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @changesets_rollback(@get_changesets()).then =>
        resolve()

  changeset_persist: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @changesets_save(@get_changesets()).then =>
        resolve()

  get_changesets: ->
    changesets = ember.makeArray(@get('changeset'))