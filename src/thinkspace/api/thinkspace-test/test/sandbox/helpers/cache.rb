module Test::Sandbox::Helpers::Cache
extend ActiveSupport::Concern
included do

  def current_ability; @controller.send :current_ability; end
  def cache_clear;     @controller.send :controller_cache_clear; end
  def cache_debug_on;  @controller.controller_cache_debug_on; end
  def cache_debug_off; @controller.controller_cache_debug_on; end

  # Override serializer_options methods to return a specific value (so do not need totem_action_authorize).
  def params_ownerable(user); serializer_options.send :define_singleton_method, :params_ownerable do; user; end; end
  def authable_ability;       serializer_options.send :define_singleton_method, :authable_ability do; Hash.new; end; end

  def set_instance_var(records)
    record = Array.wrap(records).first
    var = record.class.name.demodulize.downcase
    var = var.pluralize if records.is_a?(Array) || records.respond_to?(:to_ary)
    @controller.instance_variable_set("@#{var}".to_sym, records)
  end

  def print_spaces_cache_key(key, title=nil, print_split_key=true)
    print_cache_key(key, title)
    return unless print_split_key
    split_on = [
      '/ownerable',
      '/space',
      '/assignments',
      '/space_users',
      '/owners',
      '/assignments',
      '/cache_options',
      '/ability:cache',
      ':method',
      ([':options_key'] * 5),
    ]
    print_split_key(key, split_on)
  end

  def print_assignment_cache_key(key, title=nil, print_split_key=true)
    print_cache_key(key, title)
    return unless print_split_key
    split_on = [
      '/ownerable',
      '/assignment',
      '/phases',
      '/phase_states',
      '/phase_scores',
      '/cache_options',
    ]
    print_split_key(key, split_on)
  end

  def print_phase_cache_key(key, title=nil, print_split_key=true)
    print_cache_key(key, title)
    return unless print_split_key
    split_on = [
      '/phase/',
      '/phase_template',
      '/configuration',
      '/phase_components',
      '/team_category',
      '/resource_tags',
      '/resource_files',
      '/resource_links',
      '/cache_options',
      ([':options_key'] * 5),
    ]
    print_split_key(key, split_on)
  end

  def print_split_key(key, split_on)
    puts '  ' + split_string_by_keys(key, split_on).join("\n    ")
  end

  def print_cache_key(key, title=nil)
    puts "\n\n"
    puts "#{title.to_s.ljust(80,'-')}"  if title.present?
    puts "KEY: (#{key.length})", key.inspect
    puts "\n"
  end

  def split_string_by_keys(split_str, keys)
    strs = Array.new
    str  = split_str.to_s
    pkey = ''
    Array.wrap(keys).flatten.each do |key|
      part1, part2 = str.split(key, 2)
      strs.push(pkey + part1) if part1.present?
      str  = part2 || ''
      pkey = key.to_s
    end
    strs.push(pkey + str) if str.present?
    strs
  end

end; end
