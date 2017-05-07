#########################################################################################
# ###
# ### Institutions and Institution Users.
# ###

def casespace_seed_config_add_institutions(config)
  ins = [config[:institutions]].flatten.compact
  return if ins.blank?
  seed_config_message('++Adding seed config institutions.', config)
  ins.each do |hash|
    hash[:state] ||= :active
    institution = find_or_create_institution(hash)
    seed_config_models.add(config, institution)
  end
end

def casespace_seed_config_add_institution_users(config)
  ius = [config[:institution_users]].flatten.compact
  return if ius.blank?
  seed_config_message('++Adding seed config institution users.', config)
  ius.each do |hash|
    institutions = [hash[:institutions]].flatten.compact
    next if institutions.blank?
    users = [hash[:users]].flatten.compact
    next  if users.blank?
    state = hash[:state] || :active
    role  = hash[:role]
    institutions.each do |title|
      institution = find_institution(title: title)
      seed_config_error "Institution users institution #{title.inspect} not found [institution_users: #{hash.inspect}].", config  if institution.blank?
      users.each do |user_hash|
        user = find_or_create_casespace_user(user_hash.except(:role))
        next if user.superuser?  # do not add a space user record for a superuser
        iu = create_institution_user institution: institution, user: user, role: role, state: state
        seed_config_models.add(config, iu)
      end
    end
  end
end

def find_or_create_institution(*args)
  options     = args.extract_options!
  institution = find_institution(options)
  return institution if institution.present?
  create_institution(options)
end

def find_institution(*args)
  options = args.extract_options!
  title   = options[:title]
  return nil if title.blank?
  @seed.model_class(:common, :institution).find_by(title: title)
end

def create_institution(*args)
  options     = args.extract_options!
  institution = @seed.new_model(:common, :institution, options)
  @seed.create_error(institution)  unless institution.save
  institution
end

def create_institution_user(*args)
  options = args.extract_options!
  iu      = @seed.new_model(:common, :institution_user, options)
  @seed.create_error(iu)  unless iu.save
  iu
end
