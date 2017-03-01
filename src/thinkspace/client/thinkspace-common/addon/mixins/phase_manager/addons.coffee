import ember from 'ember'

export default ember.Mixin.create

  has_addon_ownerable:         -> @addons.has_addon_ownerable()
  has_active_addons:           -> @addons.has_active_addons()
  get_active_addons:           -> @addons.get_active_addons().copy()
  get_active_addon_ownerable:  -> @addons.get_active_addon_ownerable()
  get_active_addon_components: -> @addons.get_active_addon_components()

  set_addon_ownerable_and_generate_view: (ownerable) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @view_is_generated_off()
      @show_loading_outlet()
      # Using run.next to allow templates to rerender based on 'view_is_generated' turned off and
      # before generating the phase view with the new ownerable.
      ember.run.next =>
        @addons.set_active_addon_ownerable(ownerable)
        @set_ownerable(ownerable).then =>
          @generate_view_with_ownerable().then =>
            @hide_loading_outlet()
            resolve()

  # TODO: close the addons on an error or should addons close themselves?
  validate_and_set_addon_ownerable: ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve() unless (@has_active_addons() and @has_addon_ownerable())
      ownerable = @get_active_addon_ownerable()
      promises  = []
      for component in @get_active_addon_components()
        promises.push @validate_addon_ownerable(component, ownerable)
      ember.RSVP.Promise.all(promises).then =>
        @set_ownerable(ownerable).then => resolve()
      , (error) =>
        @addons.set_active_addon_ownerable(null)
        @set_ownerable(null).then => resolve()

  validate_addon_ownerable: (component, ownerable) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve() unless @util.is_object_function(component, 'valid_addon_ownerable')
      component.valid_addon_ownerable(ownerable).then =>
        resolve()
      , (error) =>
        reject(error)
