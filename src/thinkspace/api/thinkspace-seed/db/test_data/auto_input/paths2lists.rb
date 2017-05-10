class AutoInputPaths2Lists < AutoInputBase

  def process(options)
    phase_ids = get_phase_ids(options)
    return if phase_ids.blank?
    Rake::Task[rake_task].reenable
    Rake::Task[rake_task].invoke(*phase_ids)
  end

  def get_phase_ids(options)
    titles = options[:only]
    return nil if titles.blank?
    phases = Array.new
    titles.each do |title|
      phase = find_phase_by_title(title)
      error "Phase title #{title.inspect} not found."  if phase.blank?
      phases.push(phase)
    end
    phases.map {|p| p.id.to_s}
  end

  def rake_task; 'thinkspace:migrate:diagnostic_paths_to_indented_lists:phases'; end

end
