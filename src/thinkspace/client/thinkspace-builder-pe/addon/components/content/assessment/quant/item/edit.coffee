import ember             from 'ember'
import base              from 'thinkspace-base/components/base'
import changeset_helpers from 'thinkspace-common/mixins/helpers/common/changeset'

###
# # edit.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend changeset_helpers,

  has_comments:      ember.computed.reads 'model.settings.comments.enabled'

  manager:           ember.inject.service()

  changeset:         ember.computed.reads 'model.changeset'
  points_changeset:  ember.computed.reads 'model.points_changeset'
  label_changeset:   ember.computed.reads 'model.label_changeset'

  assessment:        ember.computed.reads 'manager.model'
  points_per_member: ember.computed.reads 'assessment.points_per_member'

  min: ember.computed 'points_per_member', ->
    min = new Array
    ppm = if ember.isPresent(@get('points_per_member')) then @get('points_per_member') else 10

    for i in [1..(ppm*1.5-1)]
      obj = {}
      obj.value = i
      obj.is_selected = parseInt(@get('model.points_changeset.min')) == i
      min.pushObject(obj)
    min

  max: ember.computed 'points_per_member', ->
    max = new Array
    ppm = if ember.isPresent(@get('points_per_member')) then @get('points_per_member') else 10

    for i in [1..(ppm*1.5)]
      obj = {}
      obj.value = i
      obj.is_selected = parseInt(@get('model.points_changeset.max')) == i
      max.pushObject(obj)
    max

  ## Temp methods until nested properties are supported by ember-changeset
  update_model: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model      = @get('model')
      changesets = model.get_changesets()
      
      @determine_validity(changesets).then (validity) =>
        console.log('[quant edit] is_valid is valid? ', validity)

        if validity
          changesets.forEach (changeset) =>

            console.log('PRE saving changeset with ', changeset)

            changeset.save()

            console.log('POST saving changeset with ', changeset)
            console.log('model props are ', @get('model'))
        
        resolve(validity)

  init_base: ->
    console.log('calling init')

    @set('display_min', {value: @get('model.points_changeset.min')})
    
    @set('display_max', {value: @get('model.points_changeset.max')})
    console.log('display_min, display_max ', @get('display_min'), @get('display_max'))

  display_min: null
  display_max: null

  actions:
    toggle_has_comments: -> @toggleProperty 'has_comments'

    edit: -> @sendAction('edit', false)

    update: -> @update_model().then (valid) => @sendAction('update') if valid

    duplicate: -> @sendAction('duplicate')

    delete: -> @sendAction('delete')

    select_points_min: (val) ->
      @set('display_min', val)
      @get('model').set('points_changeset.min', val.value)
      @get('model').set('points_changeset.max', @get('model.points_changeset.max'))

      console.log('calling select_points_min with param ', val)

    select_points_max: (val) ->
      @set('display_max', val)
      @get('model').set('points_changeset.max', val.value)
      @get('model').set('points_changeset.min', @get('model.points_changeset.min'))
      console.log('calling select_points_max with param ', val)