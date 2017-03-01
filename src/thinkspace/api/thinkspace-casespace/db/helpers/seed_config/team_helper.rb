#########################################################################################
# ###
# ### Teams.
# ###

def casespace_seed_config_add_teams(config)
  teams = config[:teams]
  return if teams.blank?
  case
  when teams.is_a?(Hash)
    casespace_seed_config_add_teams_in_hash(config, teams)
  when teams.is_a?(Array)
    teams.each do |teams_hash|
      casespace_seed_config_error "Teams is not a hash #{teams_hash.inspect}.", config unless teams_hash.is_a?(Hash)
      casespace_seed_config_add_teams_in_hash(config, teams_hash)
    end
  else
    casespace_seed_config_error "Teams must be a hash or array of hashes.", config
  end
end

def casespace_seed_config_add_teams_in_hash(config, teams_hash)
  casespace_config_models.set_find_by(config)
  casespace_seed_config_message('++Adding seed config teams.', config)
  casespace_seed_config_add_team_sets(config, teams_hash)
  casespace_seed_config_add_team_set_teams(config, teams_hash)
  casespace_seed_config_add_assignment_teams(teams_hash)
  casespace_seed_config_add_phase_teams(teams_hash)
  casespace_seed_config_add_team_viewers(teams_hash)
end

# ###
# ### Team Sets.
# ###

def casespace_seed_config_add_team_sets(config, teams_hash)
  team_sets_hash = teams_hash[:team_sets]
  return if team_sets_hash.blank?
  space = nil
  team_sets_hash.each_with_index do |hash, index|
    title = hash[:space]
    if title.present?
      space = find_casespace_space(title: title)
      casespace_seed_config_error "Space title #{title.inspect} not found." if space.blank?
    end
    casespace_seed_config_error "Team set must define a space or be inherited [#{hash.inspect}]." if space.blank?
    title = hash[:title] || "generated_team_set_#{index + 1}"
    team_set = casespace_seed_config_find_team_team_set(space_id: space.id, title: title)
    if team_set.present? && casespace_dup_skip?(hash)
      casespace_config_models.add(config, team_set)
      next
    end
    casespace_seed_config_error "Team set #{title.inspect} already exists for space #{hash[:space].inspect}"  if team_set.present?
    description = hash[:description] || "description for #{title}"
    settings    = hash[:settings]    || Hash.new
    state       = hash[:state]
    team_set    = create_team_team_set(
      space:       space,
      title:       title,
      description: description,
      settings:    settings,
      state:       state,
    )
    casespace_config_models.add(config, team_set)
  end
end

# ###
# ### Team Set - Teams and Users.
# ###

def casespace_seed_config_add_team_set_teams(config, teams_hash)
  team_set_teams_hash = teams_hash[:team_set_teams]
  return if team_set_teams_hash.blank?
  space    = nil
  team_set = nil
  team_set_teams_hash.each_with_index do |hash, index|
    title = hash[:space]
    if title.present?
      space = find_casespace_space(title: title)
      casespace_seed_config_error "Space title #{title.inspect} not found." if space.blank?
    end
    casespace_seed_config_error "Team set teams space has not been specified and is not inheritable [#{hash.inspect}]."  if space.blank?
    title = hash[:team_set]
    if title.present?
      team_set = casespace_seed_config_find_team_team_set(space_id: space.id, title: title)
      casespace_seed_config_error "Team set #{title.inspect} for space #{space.title.inspect} not found." if team_set.blank?
    end
    casespace_seed_config_error "Team set has not been specified and is not inheritable [#{hash.inspect}]."  if team_set.blank?
    title = hash[:title]       || "generated_team_set_#{index + 1}"
    team  = casespace_seed_config_find_team_team(team_set_id: team_set.id, title: title)
    if team.present? && casespace_dup_skip?(hash)
      casespace_config_models.add(config, team)
      next
    end
    description = hash[:description] || "description for #{title}"
    state       = hash[:state]
    color       = hash[:color]
    team        = create_team_team(
      title:       title,
      description: description,
      color:       color,
      state:       state,
      authable:    space,
      team_set:    team_set,
    )
    casespace_config_models.add(config, team)
    casespace_seed_config_create_team_users(team, hash)
  end
end

def casespace_seed_config_create_team_users(team, hash)
  user_names = hash[:users]
  return if user_names.blank?
  users = get_common_users_from_first_names(user_names)
  users.each do |user|
    create_team_team_user(
      team: team,
      user: user,
    )
  end
end

# ###
# ### Assignment/Phase TeamSet Teamables.
# ###

def casespace_seed_config_add_assignment_teams(teams_hash)
  assignment_teams = teams_hash[:assignment]
  return if assignment_teams.blank?
  space = nil
  assignment_teams.each_with_index do |hash, index|
    title = hash[:space]
    if title.present?
      space = find_casespace_space(title: title)
      casespace_seed_config_error "Assignment teams space title #{title.inspect} not found." if space.blank?
    end
    casespace_seed_config_error "Assignment team space has not been specified and is not inheritable [#{hash.inspect}]."  if space.blank?
    title = hash[:title]
    casespace_seed_config_error "Assignment team title is blank [#{hash.inspect}]." if title.blank?
    assignment = find_casespace_assignment(space_id: space.id, title: title)
    casespace_seed_config_error "Assignment title #{title.inspect} for space #{space.title.inspect} not found [#{hash.inspect}]." if assignment.blank?
    casespace_seed_config_add_team_set_teamables(space, assignment, hash)
  end
end

def casespace_seed_config_add_phase_teams(teams_hash)
  phase_teams = teams_hash[:phase]
  return if phase_teams.blank?
  space      = nil
  assignment = nil
  phase_teams.each_with_index do |hash, index|
    title = hash[:space]
    if title.present?
      space = find_casespace_space(title: title)
      casespace_seed_config_error "Phase team space #{title.inspect} not found [#{hash.inspect}]."  if space.blank?
    end
    casespace_seed_config_error "Phase team space has not been specified and is not inheritable [#{hash.inspect}]."  if space.blank?
    title = hash[:assignment]
    if title.present?
      assignment = space.blank? ?  find_casespace_assignment(title: title) : find_casespace_assignment(title: title, space_id: space.id)
      casespace_seed_config_error "Phase team assignment #{title.inspect} not found [#{hash.inspect}]."  if assignment.blank?
    else
      casespace_seed_config_error "Phase team assignment has not been specified and is not inheritable [#{hash.inspect}]."  if assignment.blank?
    end
    title = hash[:title]
    casespace_seed_config_error "Phase title is blank for phase team [#{hash.inspect}]."  if title.blank?
    phase = find_casespace_phase(assignment_id: assignment.id, title: title)
    casespace_seed_config_error "Phase #{title.inspect} for phase team not found [#{hash.inspect}]."  if phase.blank?
    casespace_seed_config_add_team_set_teamables(space, phase, hash)
  end
end

def casespace_seed_config_add_team_set_teamables(space, teamable, hash)
  team_sets = [hash[:team_sets]].flatten.compact
  team_sets.each do |title|
    team_set = casespace_seed_config_find_team_team_set(space_id: space.id, title: title)
    casespace_seed_config_error "Team set #{title.inspect} for space #{space.title.inspect} not found." if team_set.blank?
    team_set_teamable = @seed.model_class(:team, :team_set_teamable).find_by(team_set_id: team_set.id, teamable: teamable)
    next if team_set_teamable.present?
    create_team_team_set_teamable(
      teamable: teamable,
      team_set: team_set,
    )
  end
end

def casespace_seed_config_find_team_team_set(options)
  @seed.model_class(:team, :team_set).find_by(options)
end

def casespace_seed_config_find_team_team(options)
  @seed.model_class(:team, :team).find_by(options)
end

# ###
# ### Team Viewers.
# ###

def casespace_seed_config_add_team_viewers(teams_hash)
  viewers = teams_hash[:viewers]
  return if viewers.blank?
  space      = nil
  assignment = nil
  viewers.each do |hash|
    title = hash[:space]
    if title.present?
      space = find_casespace_space(title: title)
      casespace_seed_config_error "Team viewers space title #{title.inspect} not found." if space.blank?
    end
    casespace_seed_config_error "Assignment team space has not been specified and is not inheritable [#{hash.inspect}]."  if space.blank?
    titles = [hash[:team_sets]].flatten.compact
    casespace_seed_config_error "Viewer team set titles are blank [#{hash.inspect}]."  if titles.blank?
    team_set_ids = @seed.model_class(:team, :team_set).where(space_id: space.id, title: titles).map(&:id)
    casespace_seed_config_error "Some viewer team set titles not found [#{hash.inspect}]."  unless titles.length == team_set_ids.length

    team_titles = [hash[:teams]].flatten.compact
    teams       = Array.new
    team_titles.each do |title|
      teams.push casespace_seed_config_get_team_sets_team(team_set_ids, title, hash)
    end

    usernames = [hash[:users]].flatten.compact
    users     = get_common_users_from_first_names(usernames)

    view       = [hash[:view]].flatten.compact
    view_teams = Array.new
    view.each do |title|
      view_teams.push casespace_seed_config_get_team_sets_team(team_set_ids, title, hash)
    end

    view_teams.each do |team|
      casespace_seed_config_add_team_team_viewers(team, teams)
      casespace_seed_config_add_team_team_viewers(team, users)
    end
  end
end

def casespace_seed_config_add_team_team_viewers(team, viewerables)
  return if viewerables.blank?
  viewerables.each do |viewerable|
    create_team_team_viewer(team: team, viewerable: viewerable)
  end
end


def casespace_seed_config_get_team_sets_team(team_set_ids, title, hash)
  klass   = @seed.model_class(:team, :team)
  options = {team_set_id: team_set_ids, title: title}
  count   = klass.where(options).count
  casespace_seed_config_error "Viewer team title #{title.inspect} in more than one team set [#{hash.inspect}]."  if count > 1
  team = klass.find_by(options)
  casespace_seed_config_error "Viewer team title #{title.inspect} not found [#{hash.inspect}]."  if team.blank?
  team
end
