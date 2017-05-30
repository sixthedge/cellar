@user_count = 0

def create_user(*args)
  options = args.extract_options!
  number  = options[:number] || (@user_count += 1)

  options[:first_name]     ||= "john.#{number}"
  options[:last_name]      ||= "Doe"
  options[:email]          ||= "john.doe.#{number}@sixthedge.com"
  options[:password]       ||= "password"
  # options[:identification] ||= options[:email]

  user = @seed.new_model(:common, :user, options)
  @seed.create_error(user)  if not user.save
  user
end

def get_common_user(*args)
  options = args.extract_options!
  @seed.model_class(:common, :user).find_by(options.without(:profile))
end

def get_common_users_from_first_names(names)
  [names].flatten.collect {|name| get_common_user(first_name: name)}
end
