#########################################################################################
# ###
# ### Assignments.
# ###
def casespace_seed_config_add_assignments(config)
  assignments = [config[:assignments]].flatten.compact
  return if assignments.blank?
  seed_config_message('++Adding seed config assignments.', config)
  space = nil
  assignments.each do |hash|
    title = hash[:space]
    if title.present?
      space = find_casespace_space(title: title)
      seed_config_error "Assignment space #{title.inspect} not found [assignment: #{hash.inspect}].", config  if space.blank?
    else
      seed_config_error "Space assignment has not been specified or is inheritable [assignment: #{hash.inspect}].", config  if space.blank?
    end
    title      = hash[:title] || get_casespace_assignment_default_title(space)
    release_at = get_casespace_seed_datetime_value(hash[:release_at])
    due_at     = get_casespace_seed_datetime_value(hash[:due_at], 7)
    state      = hash[:state] || :active
    settings   = hash[:settings] || Hash.new
    assignment = create_casespace_assignment hash.merge(space: space, title: title, release_at: release_at, state: state, due_at: due_at, settings: settings)
    seed_config_models.add(config, assignment)
    casespace_add_assignment_created(assignment)
  end
end

def casespace_reset_assignments_created;          @all_assignments_created = Array.new; end
def casespace_get_assignments_created;            @all_assignments_created; end
def casespace_add_assignment_created(assignment); @all_assignments_created.push(assignment); end

#########################################################################################
# ###
# ### Phases.
# ###
def casespace_seed_config_add_phases(config)
  phases = [config[:phases]].flatten.compact
  return if phases.blank?
  seed_config_message('++Adding seed config phases.', config)
  space      = nil
  assignment = nil
  template   = nil
  phases.each do |hash|
    title = hash[:space]
    if title.present?
      space = find_casespace_space(title: title)
      seed_config_error "Phase space #{title.inspect} not found [phase: #{hash.inspect}].", config  if space.blank?
    end
    title = hash[:assignment]
    if title.present?
      assignment = space.blank? ?  find_casespace_assignment(title: title) : find_casespace_assignment(title: title, space_id: space.id)
      seed_config_error "Phase assignment #{title.inspect} not found [phase: #{hash.inspect}].", config  if assignment.blank?
    else
      seed_config_error "Phase assignment has not been specified and is not inheritable [phase: #{hash.inspect}].", config  if assignment.blank?
    end
    template_name = hash[:template_name] || hash[:phase_template]
    if template_name.present?
      template = find_casespace_phase_template(name: template_name)
      seed_config_error "Phase template name #{template_name.inspect} not found [phase: #{hash.inspect}].", config  if template.blank?
    else
      seed_config_error "Phase template has not be specified and is not inheritable [phase: #{hash.inspect}].", config  if template.blank?
    end
    title = hash[:title] || get_casespace_phase_default_title(assignment)
    state = hash[:state] || :active
    if (category = hash[:team_category]).present?
      team_category = find_team_team_category(category)
      seed_config_error "Phase team category #{category.inspect} not found [phase: #{hash.inspect}].", config  if team_category.blank?
    else
      team_category = nil
    end
    phase = create_casespace_phase hash.merge(assignment: assignment, title: title, phase_template: template, state: state, team_category: team_category)
    seed_config_models.add(config, phase)
    get_casespace_phase_template_section_configs[phase.id] = hash[:sections]
  end
end
