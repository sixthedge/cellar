#########################################################################################
# ###
# ### Auto-Inputs.
# ###

# An auto-input class is instantiated and called based on the config's auto_input keys.
# For example a config with:
#   auto_input:
#     responses: {}
#     observations: {}
# would call:
#   * AutoInputResponses.new(self, @seed, seed_config_models, options)
#   * AutoInputObservations.new(self, @seed, seed_config_models, options)
# The class .rb files should be in the 'test_data/auto_input' folder (but can be in any required .rb).

def seed_config_add_auto_input(config)
  auto_input = config[:auto_input]
  return if auto_input.blank?
  @seed.message color_line("--Auto input (#{seed_config_name(config)}).", :green, :bold)
  auto_input.keys.each do |key|
    class_name = "AutoInput#{key.to_s.camelize}"
    klass      = class_name.safe_constantize
    seed_config_error "Auto input class #{class_name.inspect} does not exist.  Is it in the auto_input folder?."  if klass.blank?
    casespace_seed_config_add_auto_input_array(auto_input, key, config).each do |hash|
      casespace_seed_config_display_auto_input_options("++Auto input #{key} with options:", hash)
      klass.new(self, @seed, seed_config_models, config, hash)
    end
  end
end

def casespace_seed_config_add_auto_input_array(auto_input, key, config)
  key_values = auto_input[key]
  if key_values == true
    casespace_seed_config_add_auto_input_config_only_phases([Hash.new], config)  # auto input with default values (e.g. empty hash) for config phases
  else
    casespace_seed_config_add_auto_input_config_only_phases([key_values].flatten.compact, config) # array of hashes for config phases
  end
end

def casespace_seed_config_add_auto_input_config_only_phases(hashes, config)
  seed_config_models.set_find_by(config)
  phases     = config[:phases] || Array.new
  titles     = phases.collect {|h| h[:title]}.uniq.compact
  new_hashes = Array.new
  hashes.each do |hash|
    except      = [hash[:except]].flatten.compact
    only        = [hash[:only]].flatten.compact
    if only.present?
      missing_titles = only - titles
      seed_config_error "Auto input options[:only] phase titles missing #{missing_titles}.\n  Options: #{hash.inspect}.", config  if missing_titles.present?
      new_hashes.push(hash.deep_dup)
      next  # use the only value in the config
    end
    new_hashes.push(hash.deep_dup.merge(only: (titles - except)))  # only auto input for phases defined in config (the except values has not impact at this point; doc only)
  end
  new_hashes
end

def casespace_seed_config_display_auto_input_options(message='', options={}, max_length=130)
  @seed.message '   ' + message
  options.except(:only, :except).each do |key, value|
    if value.present? && value.inspect.length > max_length
      max  = max_length - 12
      more = value.inspect.length - max
      val  = value.inspect[0..max]
      @seed.message "     * #{key} = #{val} ...+#{more} more..."
    else
      @seed.message "     * #{key} = #{value.inspect}"
    end
  end
  casespace_seed_config_display_auto_input_options_phase_list(:only, options, max_length)
  casespace_seed_config_display_auto_input_options_phase_list(:except, options, max_length)
end

def casespace_seed_config_display_auto_input_options_phase_list(key, options, max_length)
  list = [options[key]].flatten.compact
  return if list.blank?
  names = Array.new
  list.each do |name|
    all_length = names.inspect.length
    break if all_length > max_length
    names.push name
  end
  names.push list.first if names.blank?  # include at least one
  remain = list.length - names.length
  names.push "+#{remain} more..."  if remain > 0
  @seed.message "     * #{key} #{names.inspect}"
end
