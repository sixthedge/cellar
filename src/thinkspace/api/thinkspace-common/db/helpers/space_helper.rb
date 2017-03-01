def create_space_type(*args)
  options = args.extract_options!
  if (lookup_model_class = options.delete(:lookup_model_class)).present?
    options[:lookup_model] = lookup_model_class.name.to_s.underscore.pluralize
  end
  space_type         = @seed.new_model(:common, :space_type, options)
  space_type.title ||= 'Default Space Type Title'
  @seed.create_error(space_type) unless space_type.save
  space_type
end

def create_space(*args)
  options    = args.extract_options!
  space_type = options.delete(:space_type)
  space      = @seed.new_model(:common, :space, options)
  @seed.create_error(space)  unless space.save
  space_space_type = @seed.new_model(:common, :space_space_type)
  @seed.add_association(space_space_type, :common, :space, space)
  @seed.add_association(space_space_type, :common, :space_type, space_type)
  @seed.create_error(space_space_type)  unless space_space_type.save
  space
end

def create_space_users(*args)
  options = args.extract_options!
  space   = args.shift
  users   = args.shift || []
  [users].flatten.each do |user|
    create_space_user(options.merge(space: space, user: user))
  end
end

def create_space_user(*args)
  options    = args.extract_options!
  space_user = @seed.new_model(:common, :space_user, options)
  @seed.create_error(space_user)  unless space_user.save
  space_user
end

