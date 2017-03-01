module Totem; module Cli; module HelpersEmber; module Bundle

  attr_reader :bower_components_directories
  attr_reader :node_modules_directories

  # ###
  # ### Add Bundle Version on Commands.
  # ###

  def get_bundle_command(cmd); get_command_with_bundle_version(cmd) || cmd; end

  def get_command_with_bundle_version(cmd)
    return nil if cmd.blank?
    run_cmd = get_command_line_from_command_hash(cmd)
    return nil if run_cmd.blank?
    hash = get_bundle_standardized_run_command(cmd)
    return nil if hash.blank?
    return nil if hash[:git].present?
    return nil if hash[:action] != 'install'
    app = hash[:app]
    return nil if app.blank?
    pkg = hash[:package]
    return nil if pkg.blank?
    key     = app == 'bower' ? :bower : :node
    bundle  = (bundle_lock_data[key] || Hash.new)[pkg.to_sym] || Hash.new
    version = bundle[:version]
    return nil if version.blank?
    command = cmd.deep_dup
    case key
    when :bower
      set_command_line_in_command_hash(command, run_cmd.strip + "##{version}")  unless run_cmd.match('#')
    when :node
      set_command_line_in_command_hash(command, run_cmd.strip + "@#{version}")  unless run_cmd.match('@')
    end
    command
  end

  def get_command_line_from_command_hash(cmd)
    type = cmd[:command]
    return nil if type.blank?
    case type.to_sym
    when :prompt  then cmd[:prompt_command]
    when :run     then cmd[:run_command]
    else nil
    end
  end

  def set_command_line_in_command_hash(cmd, new_cmd)
    type = cmd[:command]
    return nil if type.blank?
    case type.to_sym
    when :prompt  then cmd[:prompt_command] = new_cmd
    when :run     then cmd[:run_command]    = new_cmd
    end
  end

  # ###
  # ### Bundle Commands for Missing Modules.
  # ###

  def get_bundle_run_commands
    paths        = Array.new
    run_commands = Array.new
    commands     = get_bundle_standardized_run_commands
    gen_commands = generate_additional_package_commands(commands)
    commands.merge(gen_commands).each do |pkg, hash|
      cmd_path = hash[:command_path]
      cmd      = hash[:original_command]
      ibower   = hash[:installed_bower]
      inode    = hash[:installed_node]
      post     = hash[:post_install] || Array.new
      git      = hash[:git]

      case

      when !ibower && !inode
        unless paths.include?(cmd_path)
          run_commands.push(command: :comment, say: "Running commands from #{cmd_path.inspect}", args: :yellow)
          paths.push(cmd_path)
        end
        run_commands.push(cmd)
        post.each {|h| run_commands.push(h[:original_command])}

      when inode
        next if ember_cli_package?(pkg)  # don't uninstall ember-cli even if different version
        iver = hash[:installed_node_version]
        bver = get_package_bundle_lock_node_version(pkg)
        if iver.present? && bver.present? && iver != bver
          if bundle_uninstall?
            run_commands += generate_node_bundle_uninstall_commands(hash, pkg)
            run_commands.push get_bundle_command(hash[:original_command])
            post.each {|h| run_commands.push(h[:original_command])}
          else
            say_message "Installed node package #{pkg.to_s.inspect} version #{iver.inspect} differs from bundle lock version #{bver.inspect}", :yellow
          end
        end

      when ibower && git && get_package_bundle_lock_bower_version(pkg) == hash[:version]

      when ibower
        iver = hash[:installed_bower_version]
        bver = get_package_bundle_lock_bower_version(pkg)
        if iver.present? && bver.present? && iver != bver
          if bundle_uninstall?
            run_commands += generate_bower_bundle_uninstall_commands(hash, pkg)
            run_commands.push get_bundle_command(hash[:original_command])
            post.each {|h| run_commands.push(h[:original_command])}
          else
            say_message "Installed bower package #{pkg.to_s.inspect} version #{iver.inspect} differs from bundle lock version #{bver.inspect}", :yellow
          end
        end

      end

    end
    bundle_lock_versions? ? run_commands.map {|c| get_bundle_command(c)} : run_commands
  end

  # Generate additional packages that are in the bundle.lock file but do not have
  # an install command (e.g. ember-cli installed packackes such as ember, ember-data).
  def generate_additional_package_commands(commands)
    gen_cmds   = Hash.new
    node_pkgs = ['ember-data'].map {|p| p.to_sym}
    node_pkgs.each do |pkg|
      next if commands.has_key?(pkg)
      next if gen_cmds.has_key?(pkg)
      version = get_installed_package_version(pkg.to_s) || 'new'
      gen_hash = {
        installed_node:         true,
        installed_node_version: version,
        original_command:       get_bundle_hash_prompt_command("npm install --save-dev #{pkg}"),
      }
      generate_node_bundle_post_install_commands(pkg, gen_hash)
      gen_cmds[pkg] = gen_hash
    end
    bower_pkgs = ['ember'].map {|p| p.to_sym}
    bower_pkgs.each do |pkg|
      next if commands.has_key?(pkg)
      next if gen_cmds.has_key?(pkg)
      version = get_installed_bower_version(pkg.to_s) || 'new'
      gen_hash = {
        installed_bower:         true,
        installed_bower_version: version,
        original_command:        get_bundle_hash_prompt_command("bower install --save #{pkg}"),
      }
      gen_cmds[pkg] = gen_hash
    end
    gen_cmds
  end

  # Add custom commands e.g. a npm install for 'ember-data' does not install ember-data in bower_components.
  def generate_node_bundle_post_install_commands(pkg, gen_hash)
    # case pkg
    # when 'ember-data'.to_sym
    #   post_hash = {package: pkg}
    #   lock_ver  = get_package_bundle_lock_node_version(pkg)
    #   post      = (gen_hash[:post_install] ||= Array.new)
    #   post.push post_hash.merge(original_command: get_bundle_hash_prompt_command("bower uninstall --save ember-data"))
    #   post.push post_hash.merge(original_command: get_bundle_hash_prompt_command("bower install --save ember-data##{lock_ver}"))
    # end
  end

  def generate_node_bundle_uninstall_commands(hash, pkg)
    cmds = Array.new
    cmds.push get_bundle_hash_prompt_command("npm uninstall --save-dev #{pkg}").merge(installed_version: hash[:installed_node_version])
    (hash[:node_related] || Hash.new).keys.each do |node_pkg|
      cmds.push get_bundle_hash_prompt_command("npm uninstall --save-dev #{node_pkg}")
    end
    (hash[:bower_related] || Hash.new).keys.each do |bower_pkg|
      cmds.push get_bundle_hash_prompt_command("bower uninstall --save #{bower_pkg}")
    end
    cmds
  end

  def generate_bower_bundle_uninstall_commands(hash, pkg)
    cmds = Array.new
    cmds.push get_bundle_hash_prompt_command("bower uninstall --save #{pkg}")
    cmds
  end

  # Using a 'prompt' command incase the install/uninstall requires a user prompt (e.g. ember will raise a
  # 'depends on' conflict when uninstalled).
  # Note: 'install' commands use the command in the command file (e.g. may be a string or prompt).
  def get_bundle_hash_prompt_command(cmd); {command: :prompt, prompt_command: cmd}; end

  # ###
  # ### Standardize Command Values.
  # ###

  def get_bundle_standardized_run_commands
    array = Array.new
    array.push(package: 'ember-cli', action: 'install')
    all_commands.each do |cmd|
      file    = cmd[:command_file] || ''
      options = {command_file: file, command_path: File.dirname(file)}
      hash    = get_bundle_standardized_run_command(cmd.except(:command_file, :command_path), options)
      array.push(hash)  if hash.present?
    end
    set_bower_components_directories
    set_node_modules_directories
    commands = Hash.new
    array.each do |hash|
      package = hash[:package]
      next if package.blank?
      add_bundle_installed_modules_info(hash)
      action = hash[:action]
      if commands.has_key?(package)
        pkg        = commands[package]
        pkg_action = pkg[:action]
        if action  == pkg_action
          say "Package #{package.inspect} is a duplicate in command #{hash.inspect}.", :red
        else
          pkg[:post_install] = [pkg[:post_install], hash].flatten.compact
        end
        next
      end
      commands[package] = hash
    end
    commands.deep_symbolize_keys
  end

  def get_bundle_standardized_run_command(cmd, options={})
    stop_run "String command #{cmd.inspect} is depreciated."  if cmd.is_a?(String)
    stop_run "Command #{cmd.inspect} is not a hash."  unless cmd.is_a?(Hash)
    command = get_command_line_from_command_hash(cmd)
    return nil if command.blank?
    hash = parse_bundle_command(command).merge(options)
    hash.merge!(original_command: cmd)
    hash
  end

  def add_bundle_installed_modules_info(hash)
    pkg = hash[:package]
    return if pkg.blank?
    installed_bower     = is_bower_component?(pkg)
    installed_bower_ver = get_installed_bower_version(pkg)
    installed_node      = is_node_component?(pkg)
    installed_node_ver  = get_installed_package_version(pkg)
    hash.merge!(
      installed_bower:         installed_bower,
      installed_node:          installed_node,
      installed_bower_version: installed_bower_ver,
      installed_node_version:  installed_node_ver,
    )
    if installed_node.present? && hash[:action] == 'install'
      add_node_package_related_bower_components(pkg, hash)
      add_node_package_related_node_modules(pkg, hash)
    end
  end

  def add_node_package_related_bower_components(pkg, hash)
    case
    when pkg == 'ember-cli'
      set_node_package_related_bower_components(hash, 'ember')
    else
      comps    = Array.new
      package  = hash[:package]
      basename = package.sub('ember-cli-','').sub('ember-','')
      comps.push package  if is_bower_component?(package)
      comps.push basename if is_bower_component?(basename)
      embername = 'ember-' + basename
      cliname   = 'ember-cli-' + basename
      comps    += bower_components_directories.select {|d| d.start_with?(embername) || d.start_with?(cliname)}
      set_node_package_related_bower_components(hash, *comps)
    end
  end

  def add_node_package_related_node_modules(pkg, hash)
    case
    when pkg == 'ember-cli'
      set_node_package_related_node_modules(hash, 'ember-data')
    else
      related = node_modules_directories.select {|c| c.start_with?(pkg)} - [pkg]
      set_node_package_related_node_modules(hash, *related)
    end
  end

  def set_node_package_related_node_modules(hash, *packages)
    return if packages.blank?
    node_related = Hash.new
    packages.uniq.each do |pkg|
      version  = get_installed_package_version(pkg)
      cmd_file = hash[:command_file]
      node_related[pkg] = {version: version}
      node_related[pkg].merge!(command_file: cmd_file) if cmd_file.present?
    end
    hash[:node_related] = node_related
  end

  def set_node_package_related_bower_components(hash, *packages)
    return if packages.blank?
    bower_related = Hash.new
    packages.uniq.each do |pkg|
      version  = get_installed_bower_version(pkg)
      cmd_file = hash[:command_file]
      bower_related[pkg] = {version: version}
      bower_related[pkg].merge!(command_file: cmd_file) if cmd_file.present?
    end
    hash[:bower_related] = bower_related
  end

  def is_bower_component?(pkg); bower_components_directories.include?(pkg); end
  def is_node_component?(pkg);  node_modules_directories.include?(pkg); end

  def parse_bundle_command(command)
    return {} unless command.is_a?(String)
    parts     = command.to_s.split(' ')
    app       = parts.shift
    action    = parts.shift
    save_type = parts.shift
    package   = parts.shift
    git       = false
    version   = nil
    if package.blank? && !save_type.to_s.start_with?('-')
      package   = save_type
      save_type = nil
    end
    save_type = '--save-dev'  if save_type.blank? && app == 'ember'
    case
    when package.present? && package.match('/')
      git              = package.strip.start_with?('git:')
      package, version = package.split('#',2)  if package.match('#')
      package          = File.basename(package, '.*')
    when package.present? && app == 'bower' && package.match('#')
      package, version = package.split('#',2)
    when package.present? && package.match('@')
      package, version = package.split('@',2)
    end
    # start: custom exceptions.
    if package.present? && package.start_with?('chosen_')
      package = package.split('_',2).first
    end
    # end: custom exceptions.
    app     = app.strip       if app.present?
    action  = action.strip    if action.present?
    package = package.strip   if package.present?
    version = version.strip   if version.present?
    {app: app, action: action, package: package, version: version, save_type: save_type, git: git}
  end

  def get_installed_bower_version(package)
    filename = 'bower.json'
    ver = get_installed_package_version(package, 'bower_components')  # return the package.json version if it exists
    return ver if ver.present?
    bower_file = File.join('bower_components', package, filename)     # return the bower.json version if it exists
    ver        = nil
    if file_exist_in_app_path?(bower_file)
      json = parse_ember_app_path_json(bower_file)
      ver  = json[:version] if json.is_a?(Hash)
    end
    if ver.blank?
      bower_file = File.join('bower_components', package, '.' + filename)  # try the .bower.json to see if it has a version
      if file_exist_in_app_path?(bower_file)
        json     = parse_ember_app_path_json(bower_file)
        ver = json[:version] if json.is_a?(Hash)
      end
    end
    ver
  end

  def get_installed_package_version(package, dir='node_modules')
    filename = 'package.json'
    package_file = File.join(dir, package, filename)
    return nil unless file_exist_in_app_path?(package_file)
    json    = parse_ember_app_path_json(package_file)
    version = json.is_a?(Hash) ? json[:version] : nil
  end

  # ###
  # ### Helpers.
  # ###

  def ember_cli_package?(pkg); pkg.present? && pkg.to_s == 'ember-cli'; end

  def set_bower_components_directories
    inside File.join(@app_path,'bower_components') do
      @bower_components_directories = Dir.glob('*')
    end
  end

  def set_node_modules_directories
    inside File.join(@app_path,'node_modules') do
      @node_modules_directories = Dir.glob('*')
    end
  end

  def file_exist_in_app_path?(file)
    exist = false
    inside @app_path do
      exist = File.file?(file)
    end
    exist
  end

  def dir_exist_in_app_path?(dir)
    exist = false
    inside @app_path do
      exist = File.directory?(dir)
    end
    exist
  end

  def parse_ember_app_path_json(file)
    stop_run "#{File.join(@app_path, file).inspect} file does not exist."  unless file_exist_in_app_path?(file)
    content = nil
    inside @app_path do
      content = File.read(file)
    end
    JSON.parse(content).symbolize_keys
  end

end; end; end; end
