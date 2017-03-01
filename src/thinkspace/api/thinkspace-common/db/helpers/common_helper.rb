def set_common_seed_loader_namespaces
  @seed.message("++Setting seed loader namespaces.")
  ns_hash = {user: 'thinkspace/common/user'}
  paths   = ::Totem::Settings.config.paths(:thinkspace)
  paths.each do |hash|
    path = hash[:path]
    next unless hash[:is_engine]
    key  = path.split('/').last
    @seed.error("Namespace key #{key.inspect} is a duplicate.")  if ns_hash.has_key?(key)
    ns_hash[key.to_sym] = path
  end
  @seed.set_namespaces(ns_hash)
end

def add_users(count=5)
  users = Array.new
  count.times do |n|
    users.push create_user number: n+1
  end
  users
end

def get_users
  klass = @seed.model_class(:common, :user)
  klass.all.order(:id).to_a
end

def get_spaces
  klass = @seed.model_class(:common, :space)
  klass.all.order(:id).to_a
end

def format_ownerable(ownerable, col=:id)
  case col
  when :first_name
    "[#{ownerable.first_name}]"
  when :full_name
    "[#{ownerable.first_name} #{ownerable.last_name}]"
  when :email
    "[#{ownerable.email}]"
  when :title
    "[#{ownerable.title}]"
  else
    id = ownerable.id.to_s.rjust(2, '0')
    "[User #{id}]"
  end
end

def format_count(text, count)
  count_text = count.to_s.rjust(2, '0')
  "#{text}(#{count_text})"
end

def create_common_configuration(*args)
  options       = args.extract_options!
  configuration = @seed.new_model(:common, :configuration, options)
  configuration.configurable = options[:configurable]
  @seed.create_error(configuration) unless configuration.save
  configuration
end
