class AutoInputResponses < AutoInputBase

  def process(options={})
    roles           = [options[:roles]].flatten.compact
    user_format_col = options[:user_format_col] || :first_name

    element_class    = @seed.model_class(:input_element, :element)
    response_class   = @seed.model_class(:input_element, :response)

    elements = element_class.all.order(:id)

    elements.each do |element|
      next unless (element.element_type == 'text' || element.element_type == 'textarea')

      phase = element.authable
      next unless include_model?(phase)

      ownerables = get_phase_ownerables(phase)
      format_col = phase.team_ownerable? ? :title : user_format_col

      ownerables.each do |ownerable|
        user_id             = phase.team_ownerable? ? 1 : ownerable.id
        response            = response_class.new
        response.element_id = element.id
        response.user_id    = user_id
        response.ownerable  = ownerable
        response.value      = "#{format_ownerable(ownerable, format_col)} #{format_count('Elem', element.id)} #{format_count('Response', element.id)}"
        response.value     += " #{format_ownerable(ownerable, :id)}"  unless phase.team_ownerable?
        @seed.create_error(response)  unless response.save
      end
    end

  end

end # AutoInputResponses
