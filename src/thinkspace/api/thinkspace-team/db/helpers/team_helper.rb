def create_team_team_category(*args)
  options  = args.extract_options!
  category = @seed.new_model(:team, :team_category, options)
  @seed.create_error(category)  unless category.save
  category
end

def find_team_team_category(category)
  @seed.model_class(:team, :team_category).find_by(category: category)
end

def find_team_category_peer_review
  @seed.model_class(:team, :team_category).peer_review
end

def find_team_category_collaboration
  @seed.model_class(:team, :team_category).collaboration
end

def find_team_category_assessment
  @seed.model_class(:team, :team_category).assessment
end

def get_teams_for_teamables(*args)
  teams = Array.new
  [args].flatten.each do |teamable|
    ids = @seed.model_class(:team, :team_set_teamable).where(teamable: teamable).pluck(:team_set_id)
    teams.push @seed.model_class(:team, :team).where(team_set_id: ids)
  end
  [teams].flatten.uniq
end

def create_team_team(*args)
  options  = args.extract_options!
  teamable = options.delete(:teamable)
  team     = @seed.new_model(:team, :team, options)
  @seed.create_error(team)  unless team.save
  team
end

def create_team_team_set(*args)
  options  = args.extract_options!
  team_set = @seed.new_model(:team, :team_set, options)
  @seed.create_error(team_set) unless team_set.save
  team_set
end

def create_team_team_set_teamable(*args)
  options  = args.extract_options!
  teamable = @seed.new_model(:team, :team_set_teamable, options)
  @seed.create_error(teamable) unless teamable.save
  teamable
end

def create_team_team_user(*args)
  options   = args.extract_options!
  team_user = @seed.new_model(:team, :team_user, options)
  @seed.create_error(team_user)  unless team_user.save
  team_user
end

def create_team_team_viewer(*args)
  options = args.extract_options!
  viewer  = @seed.new_model(:team, :team_viewer, options)
  @seed.create_error(viewer)  unless viewer.save
  viewer
end
