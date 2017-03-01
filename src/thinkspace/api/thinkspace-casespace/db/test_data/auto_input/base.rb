class AutoInputBase

  def initialize(caller, seed, config_models, config, options={})
    @caller        = caller
    @seed          = seed
    @config_models = config_models
    @config        = config
    @options       = options.deep_dup
    process(options)
  end

  def find_user(*args); @caller.send :find_casespace_user, *args; end


  # Finder a single record (e.g. a find_by with options) restricted to config created models.
  def find_space(options);      @caller.send :find_casespace_space, options; end
  def find_assignment(options); @caller.send :find_casespace_assignment, options; end
  def find_phase(options);      @caller.send :find_casespace_phase, options; end
  def find_team(options);       @caller.send :find_casespace_team, options; end

  def find_space_by_title(title);      find_space(title: title); end
  def find_assignment_by_title(title); find_assignment(title: title); end
  def find_phase_by_title(title);      find_phase(title: title); end
  def find_team_by_title(title);       find_team(title: title); end
  def find_user_by_name(name);         find_user(first_name: name); end

  # Get a model's association records restriced by the config options.
  def get_space_users(space);       @caller.send :get_casespace_space_users, space, @options; end
  def get_phase_ownerables(phase);  @caller.send :get_casespace_phase_ownerables, phase, @options; end
  def get_phase_users(phase);       @caller.send :get_casespace_phase_users, phase, @options; end
  def get_phase_teams(phase);       @caller.send :get_casespace_phase_teams, phase, @options; end

  # Spaces from the config created assignments (spaces may be created in another config).
  def config_spaces; config_assignments.map {|a| @seed.get_association(a, :common, :space)}.uniq; end

  # Find assignments and phases created in the config.
  def config_assignments; assignment_class.where(id: @config_models.find_by_ids(assignment_class)); end
  def config_phases;      phase_class.where(id: @config_models.find_by_ids(phase_class)); end

  # Select "config" models based on values in the options (e.g. only, except).
  def selected_assignments; config_assignments.select {|assignment| include_model?(assignment)}; end
  def selected_phases;      config_phases.select {|phase| include_model?(phase)}; end
  def selected_phase_ids;   selected_phases.map(&:id); end
  def selected_spaces
    spaces = config_spaces
    titles = [@options[:spaces]].flatten.compact
    titles.blank? ? spaces : spaces.select {|s| titles.include?(s.title)}
  end

  def include_model?(model); @config_models.include_auto_input_model?(model, @options); end

  def space_class;      @_space_class      ||= @seed.model_class(:common, :space); end
  def assignment_class; @_assignment_class ||= @seed.model_class(:casespace, :assignment); end
  def phase_class;      @_phase_class      ||= @seed.model_class(:casespace, :phase); end

  def error(message); @caller.send :casespace_seed_config_error, message, @config; end

end
