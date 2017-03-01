import ember           from 'ember'
import base            from 'thinkspace-base/components/base'

###
# # edit.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend

  points_min:        ember.computed.reads 'model.points_min'
  points_max:        ember.computed.reads 'model.points_max'
  label:             ember.computed.reads 'model.label'
  scale_label_min:   ember.computed.reads 'model.settings.labels.scale.min'
  scale_label_max:   ember.computed.reads 'model.settings.labels.scale.max'
  has_comments:      ember.computed.reads 'model.settings.comments.enabled'

  manager:           ember.inject.service()

  changeset:         ember.computed.reads 'model.changeset'
  points_changeset:  ember.computed.reads 'model.points_changeset'

  assessment:        ember.computed.reads 'manager.model'
  points_per_member: ember.computed.reads 'assessment.points_per_member'

  min: ember.computed 'points_per_member', ->
    min = new Array
    for i in [1..@get('points_per_member')]
      min.pushObject(i)
    min

  max: ember.computed 'points_per_member', ->
    max = new Array
    for i in [1..@get('points_per_member')]
      max.pushObject(i)
    max

  ## Temp methods until nested properties are supported by ember-changeset
  update_model: ->
    new ember.RSVP.Promise (resolve, reject) =>
      changeset        = @get('changeset')
      points_changeset = @get('points_changeset')

      changesets = [changeset, points_changeset]
      @check_validities(changesets).then (validity) =>
        if validity
          changesets.forEach (changeset) =>
            changeset.save()
        
        resolve(validity)

  check_validities: (changesets) ->
    new ember.RSVP.Promise (resolve, reject) =>
      validations = ember.makeArray()
      validities  = ember.makeArray()

      changesets.forEach (changeset) =>
        validations.pushObject(changeset.validate())

      ember.RSVP.all(validations).then (valids) =>
        changesets.forEach (changeset) =>
          validities.pushObject(changeset.get('isValid'))

        resolve(!validities.contains(false))

  actions:
    toggle_has_comments: -> @toggleProperty 'has_comments'

    edit: -> @sendAction('edit', false)

    update: -> @update_model().then (valid) => @sendAction('update') if valid

    duplicate: -> @sendAction('duplicate')

    delete: -> @sendAction('delete')

    select_points_min: (val) -> @set('points_min', val)
    select_points_max: (val) -> @set('points_max', val)

  ######
  ## Legacy
  ######
  # update_model: ->
    # model           = @get 'model'
    # points_min      = @get 'points_min'
    # points_max      = @get 'points_max'
    # label           = @get 'label'
    # scale_label_min = @get 'scale_label_min'
    # scale_label_max = @get 'scale_label_max'
    # has_comments    = @get 'has_comments'

    # console.log('[edit component] scale_label_min/max', scale_label_min, scale_label_max)

    # model.set_value 'points_min',      points_min
    # model.set_value 'points_max',      points_max
    # model.set_value 'label',           label
    # model.set_value 'scale_label_min', scale_label_min
    # model.set_value 'scale_label_max', scale_label_max
    # model.set_value 'has_comments',    has_comments

    # console.info "[pa:builder:quant:settings] Model post update is: ", model