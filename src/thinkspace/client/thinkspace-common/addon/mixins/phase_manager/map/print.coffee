import ember from 'ember'

export default ember.Mixin.create

  print_map: (title='') ->
    console.warn "Phase Manager Map #{title}"
    map = @get_map()
    map.forEach (omap, ownerable) =>
      console.info "  ==> #{ownerable.toString()} [#{ownerable.get('full_name')}]"
      omap.forEach (rmap, record) =>
        console.info "    -> #{record.toString()} [#{record.get('title')}]"
        @print_key          rmap, 'has_phase_states'
        @print_phase_states rmap, 'global'
        @print_phase_states rmap, 'selected'
        @print_phase_states rmap, 'phase_states'
        if rmap.has('phases')
          ids = (rmap.get('phases') or []).mapBy('id')
          @print_log "        phase ids: ", ids
      console.log('  <==')

  print_phase_states: (map, key) ->
    return unless map.has(key)
    indent = '        '
    states = map.get(key)
    if ember.isArray(states)
      for state in states
        if ember.isArray(state)
          # for ps in state
          #   @print_phase_state(indent + '   ', ps)
        else
          line = indent + '-> phase_state:'
          @print_phase_state(line, state)
    else
      return if ember.isBlank(states)
      @print_phase_state(indent + "#{key}:", states)

  print_key: (map, key) -> @print_log("        #{key}: [#{map.get(key)}]") if map.has(key)

  print_phase_state: (line, state) -> @print_log(line + " #{state.toString()} [#{state.get('title')}]")

  print_log: (args...) -> console.log(args...)
