module Totem; module Cli; module HelpersEmber; module Common

  attr_reader :current_package
  attr_reader :all_packages
  attr_reader :all_commands
  attr_reader :command_imports

  def new?;              run_options[:new]; end
  def dry_run?;          run_options[:dry_run]; end
  def package?;          run_options[:package]; end
  def env_js?;           run_options[:environment_js]; end
  def build_js?;         run_options[:build_js]; end

  def unlink?;           run_options[:unlink]; end
  def link?;             run_options[:link]; end
  def links?;            unlink? || link?; end

  def template_paths;    (get_platform_run_options || {})[:template_paths]; end
  def template_dir;      run_options[:template_dir]; end
  def node_version;      run_options[:node_version]; end
  def ember_cli_version; run_options[:ember_cli_version]; end

  def set_ember_run_options
    set_app_path_and_app_name
    std_options = run_options[:platform_run_options] = get_standard_platform_run_options
    run_options.merge!(std_options)
    @current_package = get_merged_standard_platform_package
    run_options[:command_paths]     = get_options_paths(run_options, 'Ember command paths', :command_paths)
    @all_packages                   = get_all_packages
    @all_commands, @command_imports = get_all_commands_and_imports
  end

  # ###
  # ### Validate.
  # ###

  def ember_validate_options
    new? ? ember_validate_application_does_not_exist : ember_validate_application_exists
    ember_validate_node_version
    ember_validate_ember_cli_version
  end

  def ember_validate_node_version
    if node_version.present? && installed_node_version != node_version
      stop_run('Run Stopped.') unless yes?("Run options require node version #{node_version.inspect} but the installed version is #{installed_node_version.inspect}. Continue? [yes,no]", [:yellow])
    end
  end

  def ember_validate_ember_cli_version
    if ember_cli_version.present? && installed_ember_cli_version != ember_cli_version
      stop_run('Run Stopped.') unless yes?("Run options require ember-cli version #{ember_cli_version.inspect} but the installed version is #{installed_ember_cli_version.inspect}. Continue? [yes,no]", [:yellow])
    end
  end

  def ember_validate_application_exists
    stop_run "App path #{@app_path.inspect} does not exist."  unless File.directory?(@app_path)
    stop_run "App path #{@app_path.inspect} is not a node package (missing package.json)."  unless node_package?(@app_path)
    stop_run "App path #{@app_path.inspect} is not a node package (missing node_modules directory)."  unless File.directory?(File.join(@app_path, 'node_modules'))
  end

  def ember_validate_application_does_not_exist
    stop_run "App path #{@app_path.inspect} already exists.  Please delete and run again."  if File.exists?(@app_path) && !dry_run?
    stop_run "App root #{@app_root.inspect} does not exist.  Please create and run again."  unless File.directory?(@app_root)
    stop_run "App name #{@app_name.inspect} must be a single word of lowercase letters."    unless @app_name.match(/^[a-z]+$/)
  end

  # ###
  # ### Packages.
  # ###

  def get_all_packages
    packages = Hash.new
    paths    = run_options[:src_paths]
    excludes = [run_options[:exclude]].flatten.compact
    includes = [run_options[:include]].flatten.compact
    paths.each do |path|
      hash = Hash.new
      inside path do
        path_dirs  = Dir.glob('*').select {|d| File.directory?(d)}
        path_pkgs  = path_dirs.select {|d| node_package?(d)}
        path_pkgs.each do |pkg|
          next if skip_package?(pkg)
          next if excludes.include?(pkg)
          next if includes.present? && !includes.include?(pkg)
          next if packages.has_key?(pkg) # use the first src_path pachage
          dir      = File.join(path, pkg)
          pkg_hash = {dir: dir, version: get_package_version(dir)}
          packages[pkg] = pkg_hash
        end
      end
    end
    packages
  end

  def get_package_version(dir)
    stop_run "Package #{dir.inspect} is not a directory." unless File.directory?(dir)
    file = File.join(dir, 'package.json')
    stop_run "Package file #{file.inspect} not found." unless File.file?(file)
    get_ember_package_hash(file)['version']
  end

  def skip_package?(pkg)
    pkg.to_s.start_with?('--') # work-in-progress package
  end

  # ###
  # ### Get Commands and Imports.
  # ###

  def get_all_commands_and_imports
    std_commands = Array.new
    std_imports  = Array.new
    cmds         = (current_package[:commands] || Hash.new).dup
    pkg_file     = run_options[:package_files].first
    cmd_paths    = run_options[:command_paths] || []
    std_commands.push get_command_file_comment(pkg_file)
    cmds.each do |cmd|
      commands = Array.new
      imports  = Array.new
      run_cmd  = cmd.is_a?(Hash) ? cmd[:run] : cmd
      case
      when cmd.blank?
      when cmd.is_a?(String)
        commands = get_standardized_commands(pkg_file, run_cmd)
      when cmd.is_a?(Hash)
        run_cmd = cmd[:run]
        file = find_src_file("#{run_cmd}.yml", src_paths: cmd_paths)
        stop_run "Ember command file #{run_cmd.inspect} not found in any command path." if file.blank?
        commands.push get_command_file_comment(file)
        hash = get_yml_file_hash(file)
        stop_run "Ember command file #{file.inspect} is not a hash." unless hash.is_a?(Hash)
        cmds     = hash[:commands] || []
        commands.push *get_standardized_commands(file, cmds)
        himports = hash[:import]
        imports  = get_standardized_imports(file, himports) if himports.present?
      else
        stop_run "Unknown ember command file format #{cmd.inspect} in file #{file.inspect}."
      end
      std_commands.push(*commands) if commands.present?
      std_imports.push(*imports)   if imports.present?
    end
    [std_commands, std_imports]
  end

  def get_command_file_comment(file)
    is_pkg  = run_options[:package_files].first == file
    pad     = is_pkg ? '' : '  '
    color   = is_pkg ? :green : :blue
    name    = get_command_file_name(file)
    message = pad + "Run command file #{name.inspect} (#{file.inspect})"
    {command: :comment, say: message, args: [color]}
  end

  def get_standardized_commands(file, cmds)
    name  = get_command_file_name(file)
    array = Array.new
    Array.wrap(cmds).each do |cmd|
      case
      when cmd.is_a?(Hash)
        array.push cmd.merge(command_file: file, name: name)
      when cmd.is_a?(String)
        array.push(command: :run, run_command: cmd, command_file: file, name: name)
      else
        stop_run "Unknown command format in #{file.inspect}.  Command: #{cmd.inspect}"
      end
    end
    array
  end

  def get_command_file_name(file); file && File.basename(file).sub(/\.\w+$/,''); end

  def get_standardized_imports(file, imports)
    name  = get_command_file_name(file)
    array = Array.new
    Array.wrap(imports).each do |import|
      array.push(import: Array.wrap(import), command_file: file, name: name)
    end
    array
  end

  def node_package?(dir)
    pkg = false
    inside dir do; pkg = File.file?('package.json'); end
    pkg
  end

  def print_run_commands(run_commands, title='    Run commands:')
    count = 0
    say_newline
    say_message title, [:yellow, :bold]
    run_commands.each do |cmd|
      if cmd.is_a?(Hash) && cmd[:command] == :comment
        say_message "  --#{cmd[:say]}", :green
      else
        command  = get_command_line_from_command_hash(cmd) || ''
        command += " (v#{cmd[:installed_version]})" if cmd[:installed_version].present?
        color    = command.match(/\suninstall\s/) ? :red : :green
        say_message "  #{(count += 1).to_s.rjust(4)}. #{command}", [color, :bold]
      end
    end
    say_newline
  end

end; end; end; end
