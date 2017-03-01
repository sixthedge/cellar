import ember from 'ember'

export default ember.Mixin.create

  loaded_phase_ids: []

  view_is_generated: false  # true when the phase view has been generated - e.g. not a team selection view (addons uses it)
  view_is_generated_on:  -> @set 'view_is_generated', true
  view_is_generated_off: -> @set 'view_is_generated', false

  phase_is_loaded: ->
    phase = @get_phase()
    phase and @get('loaded_phase_ids').includes(phase.get 'id')

  generate_view: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @validate_and_set_addon_ownerable().then =>
        @generate_view_with_ownerable().then => resolve()

  generate_view_with_ownerable: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @view_is_generated_off()
      phase = @get_phase()
      @totem_scope.authable(phase)
      @set_totem_scope_view_ability().then =>
        if @phase_is_loaded()
          @build_view(phase).then => resolve()
        else
          @show_loading_outlet()
          phase_id   = phase.get('id')
          loaded_ids = @get('loaded_phase_ids')
          loaded_ids.push phase_id
          query =
            model:  phase
            id:     phase.get('id')
            action: 'load'
            data:   {}
          @totem_scope.add_ownerable_to_query(query.data)
          @ajax.object(query).then (payload) =>
            @tc.push_payload(payload)
            @set_all_phase_states().then =>
              @build_view(phase).then => resolve()

  build_view: (phase) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @debug_ownerable()
      @tvo.clear()
      @tvo.hash.set_value 'show_errors', false
      @tvo.hash.set_value 'process_validations', phase.get('configuration_validate')
      phase_template_id = phase.get 'phase_template_id'
      phase_template    = @tc.peek_record @ns.to_p('phase_template'), phase_template_id
      return reject("Phase template id [#{phase_template_id}] not in the store.")  unless phase_template
      phase.get(@ns.to_p 'phase_components').then (components) =>
        template = phase_template.get('template')
        @tvo.template.parse(template)
        console.warn @tvo
        @tvo.template.add_components(components).then =>
          @view_is_generated_on()
          phase_show = @get_current_phase_show_component()
          if phase_show and not @util.is_destroyed(phase_show)
            phase_show.set_show_phase_off()
            ember.run.schedule 'afterRender', =>
              phase_show.set_show_phase_on()
              @hide_loading_outlet()
              resolve()
          else
            @clear_current_phase_show_component()
            @hide_loading_outlet()
            resolve()
      , (error) => reject(error)
    , (error) => reject(error)
