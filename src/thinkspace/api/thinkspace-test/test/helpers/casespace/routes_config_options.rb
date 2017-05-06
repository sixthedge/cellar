class Test::Casespace::RoutesConfigOptions

  ARRAY_KEYS = [
    :only_engines, :except_engines,
    :only_controllers, :except_controllers,
    :only_actions, :except_actions,
    :readers, :updaters, :owners,
    :unauthorized_readers, :unauthorized_updaters, :unauthorized_owners,
  ]

  attr_reader :options
  attr_reader :hash_options

  def initialize(options={})
    ARRAY_KEYS.each do |key|
      options[key] = Array(options[key]).compact.uniq
    end
    @options                 = options
    @hash_options            = Array.new
    options[:only_actions]   = options[:only_actions].map   {|a| a.to_sym}
    options[:except_actions] = options[:except_actions].map {|a| a.to_sym}
    only(*options[:only])
    except(*options[:except])
  end

  def engine_match?(name); config_match?(name, options[:only_engines], options[:except_engines], :thinkspace); end

  def controller_match?(engine_name, controller_path, action)
    return false if config_match?(controller_path, options[:only_controllers], options[:except_controllers]).blank?
    return false if config_hash_match?(engine_name, controller_path, action).blank?
    true
  end

  def action_match?(action); config_match?(action, options[:only_actions], options[:except_actions]); end

  # ###
  # ### Methods 'only' and 'except' allow adding config options outside of the initial options hash.
  # ### The 'method_missing' method can also add config options.
  # ### To be applied, need to use before calling 'get_controller_classes_and_actions' or 'get_controller_route_configs'.
  # ###

  # The methods accept up to 3 args in this order: engines, controllers, actions.
  # Matches include all args, so unlikely will want multiple engines if specifiy controllers and actions.
  def only(*args);   add_hash_option(:only,   args, :only_engines); end
  def except(*args); add_hash_option(:except, args); end

  def only_users(users={})
    [:readers, :updaters, :owners, :unauthorized_readers, :unauthorized_updaters, :unauthorized_owners].each do |key|
      options[key] = Array(users[key]).compact.uniq
    end
  end

  private

  # Either 'add' values to a known options array or set the options[key] = value.
  def method_missing(key, *args)
    if key.to_s.end_with?('=')
      key          = key.to_s.sub(/\=$/,'').to_sym
      options[key] = ARRAY_KEYS.include?(key) ? [args].flatten.compact : args.first
    else
      if ARRAY_KEYS.include?(key)
        options[key] = [options[key] + args].flatten.compact.uniq
      else
        options[key] = args.first
      end
    end
  end

  def config_match?(value, only=[], except=[], only_default=nil)
    case
    when value.blank? then false
    when only_default.present? && only.blank? && except.blank? then value.to_s.match(only_default.to_s).present?
    when only.blank? && except.blank? then true
    when only.present?
      only.each {|m| return true if value.to_s.match(m.to_s)}
      false
    else
      except.each {|m| return false if value.to_s.match(m.to_s)}
      true
    end
  end

  def config_hash_match?(name, path, action)
    return true if hash_options.blank?
    have_only = hash_options.select {|h| h[:type] == :only}.present?
    matches   = Array.new
    hash_options.each do |hash|
      engines          = hash[:engines]
      controllers      = hash[:controllers]
      actions          = hash[:actions]
      engine_match     = engines.blank?     ? true : array_match?(name, engines)
      controller_match = controllers.blank? ? true : array_match?(path, controllers)
      action_match     = actions.blank?     ? true : actions.include?(action)
      matches.push(hash)  if engine_match && controller_match && action_match
    end
    types = matches.map {|h| h[:type]}
    return false if have_only && !types.include?(:only)
    return false if types.include?(:except)
    true
  end

  def array_match?(value, array)
    array.each {|m| return true if value.to_s.match(m.to_s)}
    false
  end

  def add_hash_option(type, args, key=nil)
    return if args.blank?
    engines      = Array(args[0]).compact
    controllers  = Array(args[1]).compact
    actions      = Array(args[2]).map {|a| a.to_sym}
    options[key] = (options[key] + engines).uniq  if key.present?
    hash_options.push(type: type, engines: engines , controllers: Array(args[1]).compact, actions: actions)
  end

  def init_option_array(key);  end

end
