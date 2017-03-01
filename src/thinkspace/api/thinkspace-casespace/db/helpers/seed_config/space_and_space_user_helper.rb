#########################################################################################
# ###
# ### Spaces and Space Users.
# ###

def casespace_seed_config_add_spaces(config)
  spaces = [config[:spaces]].flatten.compact
  return if spaces.blank?
  casespace_seed_config_message('++Adding seed config spaces.', config)
  spaces.each do |hash|
    hash[:title]   ||= get_default_record_title(:common, :space)
    hash[:state]   ||= :active
    sandbox_space_id = casespace_seed_config_get_sandbox_space_id(hash)
    space = create_space hash.merge(space_type: get_casespace_space_type, sandbox_space_id: sandbox_space_id)
    casespace_config_models.add(config, space)
    if hash[:is_sandbox] == true
      casespace_seed_config_error "Space cannot have both a 'sandbox' and 'is_sandbox' value.", config if space.sandbox_space_id.present?
      space.sandbox_space_id = space.id
      @seed.create_error(space) unless space.save
    end
  end
end

def casespace_seed_config_get_sandbox_space_id(hash)
  title = hash[:sandbox]
  return nil if title.blank?
  space = find_casespace_space(title: title)
  space.blank? ? nil : space.id
end

def casespace_seed_config_add_space_users(config)
  space_users = [config[:space_users]].flatten.compact
  return if space_users.blank?
  casespace_seed_config_message('++Adding seed config space users.', config)
  space_users.each do |hash|
    spaces = [hash[:spaces]].flatten.compact
    next  if spaces.blank?
    users = [hash[:users]].flatten.compact
    next  if users.blank?
    state = hash[:state] || :active
    spaces.each do |title|
      space = find_casespace_space(title: title)
      casespace_seed_config_error "Space users space #{title.inspect} not found [space_users: #{hash.inspect}].", config  if space.blank?
      users.each do |user_hash|
        roles  = [user_hash[:role] || :read].flatten.compact
        roles.each do |role|
          user  = find_or_create_casespace_user(user_hash.except(:role))
          next if user.superuser?  # do not add a space user record for a superuser
          create_space_user space: space, user: user, role: role, state: state
        end
      end
    end
  end
end

def casespace_seed_config_add_repeat_space_users(config)
  space_users = [config[:repeat_space_users]].flatten.compact
  return if space_users.blank?
  casespace_seed_config_message('++Adding seed config "repeat" space users.', config)
  space_users.each do |hash|
    repeat       = hash[:repeat] || 1
    start_number = hash[:start_number] || 1
    role         = hash[:role] || :read
    state        = hash[:state] || :active
    first_name   = hash[:first_name] || 'Jane'
    last_name    = hash[:last_name]  || 'Doe'
    zero_fill    = hash[:zero_fill] == false ? 1 : (repeat + start_number).to_s.length
    spaces       = [hash[:spaces]].flatten.compact
    spaces.each do |title|
      space = find_casespace_space(title: title)
      casespace_seed_config_error "Space users space #{title.inspect} not found [space_users: #{hash.inspect}].", config  if space.blank?
      repeat.times do
        id         = start_number.to_s.rjust(zero_fill, '0')
        user_first = "#{first_name}_#{id}"
        user_last  = "#{last_name}_#{id}"
        email      = "#{first_name.downcase}.#{last_name.downcase}.#{id}@sixthedge.com"
        user       = find_or_create_casespace_user(first_name: user_first, last_name: user_last, email: email)
        create_space_user space: space, user: user, role: role, state: state
        start_number += 1
      end
    end
  end
end
