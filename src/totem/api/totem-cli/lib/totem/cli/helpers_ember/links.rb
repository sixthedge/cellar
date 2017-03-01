module Totem; module Cli; module HelpersEmber; module Links

  def ember_unlink_packages
    pkgs = get_ember_unlink_packages
    return if pkgs.blank?
    max     = pkgs.map {|p| p.to_s.length}.max + 2
    app_dir = File.join(@app_path, 'node_modules')
    stop_run "Ember application #{app_dir.inspect} is not a directory." unless File.directory?(app_dir)
    say_message "  Unlinking packages in #{app_dir.inspect}.", run_message_color
    inside app_dir do
      pkgs.each_with_index do |pkg, index|
        if !File.symlink?(pkg)
          say_message "    #{(index+1).to_s.rjust(2)}. #{pkg.ljust(max, '.')} not symlink -- skipping unlink", :yellow if verbose?
          next
        end
        say_message "    #{(index+1).to_s.rjust(2)}. #{pkg.ljust(max, '.')}", run_message_color if verbose?
        cmd = "unlink #{pkg}"
        run cmd, capture: capture?, verbose: verbose_run?  unless dry_run?
      end
    end
  end

  def ember_link_packages
    pkgs = get_ember_link_packages
    return if pkgs.blank?
    max     = pkgs.map {|p| p.to_s.length}.max + 2
    app_dir = File.join(@app_path, 'node_modules')
    stop_run "Ember application #{app_dir.inspect} is not a directory." unless File.directory?(app_dir)
    say_message "  Linking packages in #{app_dir.inspect}.", run_message_color
    inside app_dir do
      pkgs.each_with_index do |pkg, index|
        hash = all_packages[pkg]
        dir  = hash[:dir]
        stop_run "Ember package file #{dir.inspect} does not exist." unless File.directory?(dir)
        say_message "    #{(index+1).to_s.rjust(2)}. #{pkg.ljust(max, '.')}#{dir}", run_message_color
        cmd = "ln -s #{dir} #{pkg}"
        run cmd, capture: capture?, verbose: verbose_run?  unless dry_run?
      end
    end
  end

  def ember_update_package_json
    dev_pkgs   = get_ember_app_package_json_platform_packages
    pkgs       = get_ember_link_packages
    added      = pkgs - dev_pkgs
    removed    = dev_pkgs - pkgs
    deps, json = get_ember_app_dev_dependencies
    removed.each {|p| deps.delete(p)}
    pkgs.each do |pkg|
      hash    = all_packages[pkg] || {}
      version = hash[:version]
      deps[pkg] = version
    end
    file = get_app_package_json_filename
    say_message "  Updating package.json file #{file.inspect}."
    return if dry_run?
    stop_run "Ember application package.json file #{file.inspect} does not exist." unless File.file?(file)
    json['devDependencies'] = Hash[deps.sort]
    create_file file, JSON.pretty_generate(json), verbose: verbose_run?  unless dry_run?
    if added.present? && verbose?
      say_message "  Added packages:", :green
      added.sort.each_with_index do |pkg, index|
        say "    #{(index+1).to_s.rjust(2)}. #{pkg}", :green
      end
    end
    if removed.present?
      say set_color("  Removed packages:", :red, :bold)
      removed.sort.each_with_index do |pkg, index|
        say_message "    #{(index+1).to_s.rjust(2)}. #{pkg}", :red
      end
    end
  end

  # ###
  # ### Helpers.
  # ###

  def get_ember_link_packages; all_packages.keys.sort; end

  def get_ember_unlink_packages
    pkgs     = get_ember_link_packages
    app_pkgs = get_ember_app_package_json_platform_packages # get existing platform packages (even when not in current packages).
    (app_pkgs + pkgs).uniq.sort
  end

  def get_ember_app_package_json_platform_packages
    platforms  = get_ember_platforms
    deps, hash = get_ember_app_dev_dependencies
    array      = Array.new
    deps.keys.sort.each do |pkg|
      platforms.each do |platform|
        if pkg.to_s.start_with?(platform)
          array.push(pkg)
          break
        end
      end
    end
    array
  end

  def get_ember_platforms
    @_ember_platforms ||= begin
      platforms = run_options[:platforms]
      if platforms.blank?
        platforms = Array.new
        run_options[:src_paths].each do |path|
          dir  = File.dirname(path)
          name = File.basename(dir)
          platforms.push(name) if name.present? && File.basename(path) == 'client'
        end
      end
      Array.wrap(platforms).uniq
    end
  end

  def get_ember_app_dev_dependencies
    hash = get_app_package_json
    return {} unless hash.is_a?(Hash)
    deps = hash['devDependencies'] ||= {}
    [deps, hash]
  end

  def get_app_package_json; get_ember_package_hash(get_app_package_json_filename); end

  def get_app_package_json_filename; File.join(@app_path, 'package.json'); end

  def get_ember_package_hash(file)
    return {} if dry_run? && !File.file?(file)
    stop_run "Ember application does not have a package.json file." unless File.file?(file)
    content = File.read(file)
    JSON.parse(content)
  end

end; end; end; end
