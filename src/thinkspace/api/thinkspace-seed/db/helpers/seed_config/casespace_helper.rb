@assignment_count = 0
@phase_count      = 0
@alpha            = (a=*('A'..'Z'); aa=*('AA'..'ZZ'); a+aa) # about 700 alphas

public

# ###
# ### Getters.
# ###

def get_casespace_alpha(index); @alpha[index]; end

# Used by auto input.
def get_casespace_phase_ownerables(phase, options={})
  phase.team_ownerable? ? get_casespace_phase_teams(phase, options) : get_casespace_phase_users(phase, options)
end

def get_casespace_phase_teams(phase, options={})
  teams      = [options[:teams]].flatten.compact
  assignment = @seed.get_association(phase, :casespace, :assignment)
  all_teams  = get_teams_for_teamables(phase, assignment)
  teams.blank? ? all_teams : all_teams.select {|t| teams.include?(t.title)}
end

def get_casespace_phase_users(phase, options={})
  space = phase.get_space()
  get_casespace_space_users(space, options)
end

def get_casespace_space_users(space, options={})
  roles       = options[:roles]
  users       = options[:users]
  space_users = @seed.get_association(space, :common, :space_users)
  space_users = space_users.where(role: roles)  if roles.present?
  if users.present?
    users    = [users].flatten.compact
    user_ids = users.map {|u| find_casespace_user(first_name: u)}.map(&:id)
    @seed.error "Space users for users #{users.inspect} not found."  if user_ids.blank?
    space_users = space_users.where(user_id: user_ids)
  end
  user_ids = space_users.pluck(:user_id)
  @seed.model_class(:common, :user).where(id: user_ids)
end

def get_casespace_phase_template_section_configs
  @_casespace_phase_template_section ||= Hash.new
end

def get_casespace_lab_charts
  @_casespace_lab_charts ||= Hash.new
end

# ###
# ### Finders.
# ###

def find_casespace_space(*args)
  options = args.extract_options!
  klass   = @seed.model_class(:common, :space)
  klass.find_by add_config_find_by_ids_to_options(klass, options)
end

def find_casespace_assignment(*args)
  options = args.extract_options!
  klass   = @seed.model_class(:casespace, :assignment)
  klass.find_by add_config_find_by_ids_to_options(klass, options)
end

def find_casespace_phase(*args)
  options = args.extract_options!
  klass   = @seed.model_class(:casespace, :phase)
  klass.find_by add_config_find_by_ids_to_options(klass, options)
end

def find_or_create_casespace_user(*args)
  options = args.extract_options!
  user    = find_casespace_user(options)
  return user if user.present?
  user_first = options[:first_name] || 'Jane'
  user_last  = options[:last_name]  || 'Doe'
  email      = options[:email]      || "#{user_first.downcase}@sixthedge.com"
  state      = options[:state]      || 'active'
  superuser  = options[:superuser]  || false
  profile    = options[:profile]    || {}
  create_user(first_name: user_first, last_name: user_last, email: email, state: state, superuser: superuser, profile: profile)
end

def find_casespace_team(*args)
  options = args.extract_options!
  klass   = @seed.model_class(:team, :team)
  klass.find_by add_config_find_by_ids_to_options(klass, options)
end

def add_config_find_by_ids_to_options(klass, options)
  ids = seed_config_models.find_by_ids(klass)
  return options if ids.blank?
  options.deep_dup.merge(id: ids)
end

def find_casespace_user(*args)
  options = args.extract_options!
  get_common_user(options)
end

# ###
# ### Space.
# ###

def get_casespace_space_type
  space_type = @seed.model_class(:common, :space_type).find_by(title: 'Casespace')
  @seed.error "Space type 'Casespace' not found.  Have the domain models been loaded?"  if space_type.blank?
  space_type
end

def get_casespace_space_title_id(space)
  id = space.title.split('_').last || ''
  id.match(/\D/) ? space.id : id  # if space title is like 'space_1', return '1', otherwise the record id
end

# ###
# ### Assignment.
# ###

def create_casespace_assignment(*args)
  options    = args.extract_options!
  assignment = @seed.new_model(:casespace, :assignment, options)
  assignment.title        ||= "Assignment #{@assignment_count}"
  assignment.description  ||= "Description for #{assignment.title}"
  assignment.instructions ||= "Instructions for #{assignment.title}."
  assignment.bundle_type  ||= 'casespace'
  @seed.create_error(assignment)  unless assignment.save
  @assignment_count += 1
  create_common_timetable(assignment, options)
  assignment
end

def get_casespace_assignment_default_title(space)
  space_id = get_casespace_space_title_id(space)
  id       = @seed.get_association(space, :casespace, :assignments).count + 1
  "assignment_#{space_id}_#{id}"
end

# ###
# ### Phase.
# ###

def create_casespace_phase(*args)
  options = args.extract_options!
  phase   = @seed.new_model(:casespace, :phase, options.except(:settings, :sections))
  phase.title          ||= "Phase #{phase_count}"
  phase.description    ||= "Description for #{phase.title}"
  phase.default_state  ||= 'unlocked'
  phase.position       ||= get_casespace_phase_position(phase)
  @seed.create_error(phase)  unless phase.save
  @phase_count += 1
  create_common_timetable(phase, options)
  create_casespace_phase_configuration(phase, options[:settings] || {})
  phase
end

def create_casespace_phase_configuration(phase, settings={})
  config_settings = {
    validation:             {validate: true},
    phase_score_validation: {
      numericality: {
        allow_blank:              false,
        greater_than_or_equal_to: 1,
        less_than_or_equal_to:    1000,
        decimals:                 0,
      },
    },
  }.deep_merge(settings)
  if phase.has_attribute?(:settings)
    phase.settings = config_settings
    @seed.create_error(phase)  unless phase.save
  else
    create_common_configuration(configurable: phase, settings: config_settings)
  end
end

def get_casespace_phase_position(phase)
  assignment = @seed.get_association(phase, :casespace, :assignment)
  assignment.thinkspace_casespace_phases.count + 1
end

def get_casespace_phase_default_title(assignment)
  space    = @seed.get_association(assignment, :common, :space)
  space_id = get_casespace_space_title_id(space)
  id       = @seed.get_association(space, :casespace, :assignments).find_index(assignment) || 0
  index    = @seed.get_association(assignment, :casespace, :phases).count
  "phase_#{space_id}_#{id+1}_#{get_casespace_alpha(index)}"
end

# ###
# ### Common Timetable.
# ###

def create_common_timetable(record, options={})
  release_at = options[:release_at]
  due_at     = options[:due_at]
  return if release_at.blank? && due_at.blank?
  user      = options[:user]
  ownerable = options[:ownerable]
  da        = @seed.new_model(:common, :timetable, timeable: record, release_at: release_at, due_at: due_at, ownerable: ownerable, user: user)
  @seed.create_error(da)  unless da.save
  da
end

# ###
# ### Generic.
# ###

def get_default_record_title(namespace, model)
  name = model.to_s
  id = @seed.model_class(namespace, model).maximum(:id) || 0
  "#{name}_#{id + 1}"
end

def casespace_seed_config_process_value_string_or_symbol?(value); value.instance_of?(String) || value.instance_of?(Symbol); end

def casespace_seed_config_get_user_name_username(user)
  username = user[:first_name] || user[:name] || 'unknown'
  username.to_sym
end

def get_casespace_seed_datetime_value(days, default=0)
  days = default  if days.nil?
  begin
    days = days.to_i
  rescue
    days = default.to_i
  end
  DateTime.now + days.days
end

def casespace_dup_skip?(hash); hash[:dup] == 'skip'; end
