#########################################################################################
# ###
# ### Users (only when not added by space users e.g. superuser).
# ###

def casespace_seed_config_add_users(config)
  users = [config[:users]].flatten.compact
  return if users.blank?
  casespace_seed_config_message('++Adding seed config users.', config)
  users.each do |hash|
    casespace_seed_config_add_user(hash)
  end
end

def casespace_seed_config_add_user(hash)
  find_or_create_casespace_user(hash)
end

