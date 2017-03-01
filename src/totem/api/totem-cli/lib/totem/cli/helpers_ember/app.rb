module Totem; module Cli; module HelpersEmber; module App

  def ember_cli_is_installed?;  ember_cli_is_installed; end

  def create_ember_app
    stop_run "ember-cli is not installed.  Please install and re-run."  if !ember_cli_is_installed?
    @public_is_installed = false
    install_ember_application
  end

  def install_ember_application
    say_message "Clean the bower and npm caches.", run_message_color
    run_ember_app_string_command 'bower cache clean'
    run_ember_app_string_command 'npm cache clean'
    name = set_color(@app_name.to_s.inspect, :bold)
    path = set_color("in path #{@app_root.inspect}.", do_message_color)
    say_message "Creating ember-cli app #{name} #{path}", do_message_color
    inside @app_root do
      run_ember_app_string_command "ember new #{@app_name}"
    end
    run_ember_app_commands
  end

  def run_ember_app_commands
    inside @app_path do
      all_commands.each do |cmd|
        run_ember_app_command(cmd)
      end
    end
  end

  def run_ember_app_command(cmd)
    case
    when (mod = skip_npm_uninstall?(cmd)).present?
      say_message "Skipping uninstall command #{cmd.inspect}.  Node module #{mod.inspect} does not exist.", :yellow
    when cmd.kind_of?(String) && cmd.strip == 'noop' # e.g. - run: noop
      say_message "Running noop command."
    when cmd.kind_of?(String)
      say_message "String commands are depreciated.  #{cmd.inspect} should have been auto-converted into a hash :run command", :yellow
    when cmd.kind_of?(Hash)
      run_ember_app_hash_command(cmd)
    else
    end
  end

  def skip_npm_uninstall?(cmd)
    return false unless cmd.kind_of?(String)
    return false unless cmd.match(/^\s*npm\s+uninstall/)
    mod = cmd.split.select {|p| !p.start_with?('-')}.last
    return false if mod.blank?
    return mod unless File.directory? File.join('node_modules', mod)
    false
  end

  def run_ember_app_string_command(cmd)
    say_message "    running: #{cmd.inspect}", :cyan
    run cmd, capture: capture?, verbose: verbose_run?  unless dry_run?
  end

  def run_ember_app_hash_command(cmd)
    command = cmd[:command]
    stop_run "Hash command #{cmd.inspect} does not have a command."  if command.blank?
    case command.to_sym

    when :run
      command = bundle_lock_versions? ? get_bundle_command(cmd) : cmd
      command = command[:run_command]
      stop_run "Hash run command #{cmd.inspect} does not have a run_command key."  if command.blank?
      stop_run "Hash run_command value #{cmd.inspect} is not a string."  unless command.is_a?(String)
      run_ember_app_string_command(command)

    when :prompt
      command = bundle_lock_versions? ? get_bundle_command(cmd) : cmd
      command = command[:prompt_command]
      sel_cmd = ''
      stop_run "Prompt command missing."  if command.blank?
      selections = [cmd[:select]].flatten.compact
      say_msg    = cmd[:say]
      if selections.present?
        if selections.length == 1
          sel_cmd = "echo '#{selections.first}' | "
        else
          # Until find a solution to automate multiple selections, generate a message for the user.
          user_action_message say_msg  if say_msg.present?
          say_msg = "Following command requires multiple selections.  Recommended selections #{selections.inspect}."
        end
      end
      user_action_message say_msg  if say_msg.present?
      say_message "    running: #{sel_cmd}#{command.inspect}.", :cyan
      run sel_cmd + command, capture: false, verbose: verbose_run?  unless dry_run?

    when :comment
      args = [cmd[:args] || []].flatten.compact.map {|a| a.is_a?(String) ? a.to_sym : a}
      say_message cmd[:say], *args

    when :bower_version
      file = 'bower.json'
      stop_run "#{file.inspect} file does not exist."  unless File.file?(file)
      hash = get_ember_command_json(file)
      package = cmd[:package]
      stop_run "bower.json version requires a package."  if package.blank?
      dependencies = hash['dependencies']
      stop_run "bower.json does not have a dependencies section."  if dependencies.blank?
      from = dependencies[package]
      to   = cmd[:to] || get_ember_command_package_json_version(package)
      stop_run "bower.json version requires a new to version."  if to.blank?
      say_message "Change bower.json #{package.inspect} version from #{from.inspect} to #{to.inspect}", run_message_color
      dependencies[package] = to
      create_file file, get_ember_command_hash_to_json(hash), verbose: verbose_run?  unless dry_run?

    when :clear_bower_components
      dir = 'bower_components'
      stop_run "Bower components directory does not exist."  unless File.directory?(dir)
      say_message "Clearing bower components directory.", run_message_color
      inside dir do
        ::FileUtils.rm_rf Dir.glob("*")  unless (pretend? or dry_run?)
      end

    when :delete_file
      file = cmd[:file]
      stop_run "Delete file command 'file' key is blank."  if file.blank?
      stop_run "Delete file command 'file' key cannot be an absolute path (e.g. start with a /)."  if file.start_with?('/')
      stop_run "Delete file command file #{file.inspect} does not exist."  if !File.file?(file) && !dry_run?
      say_message "Deleting file #{file.inspect}", run_message_color
      ::FileUtils.rm(file)  unless (pretend? or dry_run?)

    when :clean_up_app_directory
      return if dry_run?
      dir = 'app'
      stop_run "App directory does not exist."  unless File.directory?(dir)
      remove_files = ['router.js', 'styles/app.css', 'resolver.js']
      compass      = cmd[:compass] || false
      inside dir do
        app_dirs  = Dir.glob('*').select {|d| File.directory?(d)}
        app_dirs -= ['styles']
        if app_dirs.present?
          say_message "  remove '#{dir}' directories #{app_dirs.inspect}."
          app_dirs.each do |app_dir|
            ::FileUtils.rm_rf(app_dir)  unless (pretend? or dry_run?)
          end
        end
        say_message "  remove '#{dir}' files #{remove_files.inspect}."
        remove_files.each do |file|
          next unless File.file?(file)
          ::FileUtils.rm(file)  unless (pretend? or dry_run?)
        end
        file    = compass.present? ? "styles/#{@app_name}.scss" : "styles/app.scss"
        content = "@import 'master';\n"
        say_message "  creating '#{dir}/#{file}'."
        create_file file, content, verbose: verbose_run?  unless dry_run?
      end

    when :copy_public
      return if dry_run?
      source = cmd[:path] || run_options[:public_path]
      stop_run "Public directory path was not specified (command 'path:' -or- package 'public_path:'."  if source.blank?
      source = File.join(@root_path, source)
      stop_run "Public directory #{source.inspect} does not exist."  unless File.directory?(source)
      destination = File.join(@root_path, @app_path, 'public')
      say_message "Copying 'public' directory contents from #{source.inspect} to #{destination.inspect}.", run_message_color
      directory source, destination, verbose: verbose_run?  unless dry_run?
      @public_is_installed = true

    when :gsub_file
      return if dry_run?
      path    = cmd[:path]
      match   = cmd[:match]
      regex   = cmd[:regex]
      replace = cmd[:replace] || ''
      stop_run "gsub file command path is blank in command #{cmd.inspect}."  if path.blank?
      stop_run "gsub file path #{path.inspect} does not exist."  unless File.file?(path)
      stop_run "gsub file command cannot have both 'match' and 'regex' in command #{cmd.inspect}."  if match.present? && regex.present?
      if match.present?
        say_message "  file #{path.inspect} gsub with match [#{match}] and replace with [#{replace}]."
        replace_gsub = match
      else
        if regex.start_with?('/')
          begin
            replace_gsub = eval "%r#{regex}"
          rescue SyntaxError => e
            say_message "Invalid gsub file command regex [#{regex}].  Do you have a slash before and after?", :red
            stop_run e.message
          end
        else
          replace_gsub = Regexp.new(regex)
        end
        text = get_ember_indented_string(replace)
        say_message "  file #{path.inspect} gsub with regex [#{regex}] and replace with:\n#{text}"
      end
      gsub_file path, replace_gsub, replace, verbose: verbose_run?  unless dry_run?

    else
      stop_run "Unsupported hash command #{command.inspect} in #{cmd.inspect}."
    end

  end

  def get_ember_indented_string(replace, color=:cyan, indent='    ')
    return replace unless replace.is_a?(String)
    text = ''
    replace.each_line do |line|
      next if text.blank? and line == "\n"
      text += indent + line
    end
    set_color(text, color)
  end

  def get_ember_command_package_json_version(package)
    get_ember_command_package_json(package)['version']
  end

  def get_ember_command_package_json(package)
    node_path  = File.join('node_modules', package, 'package.json')
    bower_path = File.join('bower_components', package, 'bower.json')
    case
    when File.file?(node_path)
      get_ember_command_json(node_path)
    when File.file?(bower_path)
      get_ember_command_json(bower_path)
    else
      stop_run "Package.json file for package #{package.inspect} not found."
    end
  end

  def get_ember_command_hash_to_json(hash)
    JSON.pretty_generate(hash)
  end

  def get_ember_command_json(path)
    content = File.read path
    JSON.parse(content)
  end

end; end; end; end
