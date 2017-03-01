class AutoInputObservations < AutoInputBase

  def process(options)
    obs_per_list       = options[:observations_per_list] || 3
    obs_per_list_lists = options[:observations_per_list_lists] || 1
    max_notes_per_obs  = options[:max_notes_per_observation] || 3
    user_format_col    = options[:user_format_col] || :first_name

    list_class = @seed.model_class(:observation_list, :list)
    obs_class  = @seed.model_class(:observation_list, :observation)
    note_class = @seed.model_class(:observation_list, :observation_note)

    phase_ids = selected_phase_ids

    list_comps = @seed.model_class(:casespace, :phase_component).where(phase_id: phase_ids, componentable_type: list_class.name).order(:id)
    lists      = list_comps.collect {|comp| comp.componentable}.uniq

    list_ids_processed = Array.new  # since lists have lists don't reprocess 

    lists.each do |list|
      next if list_ids_processed.include?(list.id)

      phase      = list.authable
      list_lists = @seed.get_association(list, :observation_list, :lists).order(:id).select {|l| !list_ids_processed.include?(l.id)}

      ownerables    = get_phase_ownerables(phase)
      number_of_obs = list_lists.many? ? obs_per_list_lists : obs_per_list

      options[:format_col] = phase.team_ownerable? ? :title : user_format_col

      ownerables.each do |ownerable|
        @ci = nil

        user_id         = phase.team_ownerable? ? 1 : ownerable.id
        position        = 0
        number_of_notes = 0

        list_lists.each do |ll|
          list_ids_processed.push ll.id
          list_phase = ll.authable
          next unless @config_models.include_auto_input_model?(list_phase, options)

          number_of_obs.times do
            obs           = obs_class.new
            obs.user_id   = user_id
            obs.ownerable = ownerable
            obs.list_id   = ll.id
            obs.position  = position += 1
            obs.value     = observation_value(phase, list_phase, obs, options)
            @seed.create_error(obs)  unless obs.save
            number_of_notes.times do |n|
              note                = note_class.new
              note.observation_id = obs.id
              note.value          = "#{format_count('Note', number_of_notes-n)} " + obs.value
              @seed.create_error(note)  unless note.save
            end
            number_of_notes += 1
            number_of_notes = 0 if number_of_notes > max_notes_per_obs
          end
     
        end
      end
    end
  end

  def observation_value(phase, list_phase, obs, options)
    fmt_col = options[:format_col]
    indent  = options[:indent]
    value   = "#{format_count('List',obs.list_id)} #{format_ownerable(obs.ownerable, fmt_col)}"
    value  += " #{format_ownerable(obs.ownerable, :id)}"  unless phase.team_ownerable?
    value  += " #{format_count('Observation', obs.position)} #{format_ownerable(list_phase, :title)} #{format_count('Phase',list_phase.id)} "
    value   = observation_indent_value(indent) + value if indent.present?
    value
  end

  def observation_indent_value(indent)
    case
    when @ci.blank?
      @ci = [1]
    when @ci.length >= indent
      i   = @ci.first + 1
      @ci = [i]
    else
      @ci.push(1)
    end
    @ci.join('.') + '. '
  end

end # AutoInputObservations
