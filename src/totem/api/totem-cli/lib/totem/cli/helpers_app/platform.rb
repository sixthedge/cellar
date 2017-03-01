module Totem; module Cli; module HelpersApp; class Platform < Thor::Group
  include Thor::Actions

  include Helpers::RailsApp
  include Helpers::RunHelpers
  include Helpers::Common
  include Helpers::Package
  include HelpersPlatform::Gemspec

  FRAMEWORK_ONLY_OPTIONS = [:gemfile, :database, :gemfile_common]
  TEMPLATE_DIRECTORY     = File.expand_path('../../helpers_platform/templates', __FILE__).to_s

  attr_reader :platform_config
  attr_reader :platform_name
  attr_reader :platform_gemspec_name
  attr_reader :run_options

  def initialize(args, local_options, config)
    args ||= []
    @run_options = Hash[args]
    config ||= {}
    local_options = get_thor_options_from_run_options
    super(args, local_options, config)
    @app_name    = run_options[:app_name]
    @app_path    = run_options[:app_path]
    @app_root    = run_options[:app_root]
  end

  def pre_process
    self.class.source_root [TEMPLATE_DIRECTORY]
    run_options[:template_dir] = TEMPLATE_DIRECTORY
    set_platform_config_with_gemspec
    @platform_gemspec_name = platform_config.gemspec_name
    @platform_name         = platform_config.gemspec_name.underscore
  end

  def validate_run_options
    stop_run "Run options is not a hash." unless run_options.is_a?(Hash)
    stop_run "App name is blank."  if @app_name.blank?
    stop_run "App path is blank."  if @app_path.blank?
    verify_options_and_gemset if verify?
    debug_run_options
  end

  def new_rails_app
    if framework? && new?
      new_rails_app_validation
      create_rails_app
    else
      stop_run "#{@app_path.inspect} is not a rails application.", :red  unless rails_application_exists?
    end
  end

  def process

    do_gemfile          if install?(:gemfile)
    do_config           if install?(:config)
    do_database         if install?(:database)

    do_application_rb   if install?(:application_rb)
    do_production_rb    if install?(:production_rb)
    do_development_rb   if install?(:development_rb)
    do_mime_types_rb    if install?(:mime_types_rb)
    do_test_rb          if install?(:test_rb)

    do_routes           if install?(:routes)
    do_secrets          if install?(:secrets)
    do_inflections      if install?(:inflections)
    do_gemfile_common   if install?(:gemfile_common)
    do_gemfile_lock     if install?(:gemfile_lock)

    do_gemfile_platform if install?(:gemfile_platform) || vendor?
    do_gem_package      if vendor?
    # do_vendor_package   if vendor?
    do_abilities        if install?(:abilities) || vendor?  # must be last incase doing a package
  end

  # ### Install based on options ### #

  # #########################
  # ### PRIVATE METHODS ### #
  # #########################

  private

  def install?(key)
    return false if !framework? && FRAMEWORK_ONLY_OPTIONS.include?(key)
    run_options[key] || run_options[:all]
  end

  def package?;    platform_config.package?; end  # override the common 'package?' method
  def deploy?;     platform_config.deploy?; end   # override the common 'deploy?' method
  def vendor?;     platform_config.vendor?; end
  def framework?;  platform_config.framework?; end

  #
  # ### DO-Support Methods ### #
  #

  def do_gemfile;        install_template('Gemfile'); end
  def do_gemfile_common; install_template('Gemfile_common.rb'); end
  def do_database;       install_template('config/database.yml'); end

  def do_gemfile_lock;   install_platform_template('Gemfile.lock');  end
  def do_production_rb;  install_platform_template('config/environments/production.rb');  end
  def do_development_rb; install_platform_template('config/environments/development.rb'); end
  def do_test_rb;        install_platform_template('config/environments/test.rb');        end
  def do_mime_types_rb;  install_platform_template('config/initializers/mime_types.rb');  end

  def do_config
    config_files = "config/totem/config_files"
    if vendor?
      install_remove_file(config_files)  if file_exists_in_app_path?(config_files)
      filename = "config/totem/#{platform_name}.config.yml"
      content  = platform_config.platform_config_to_yaml
      install_create_file(filename, content)
    else
      paths  = "# added by #{platform_config.gemspec_name.inspect}\n"
      paths += platform_config.config_paths.join("\n")
      if !framework? && file_exists_in_app_path?(config_files)
        install_append_file(config_files, "\n" + paths)
      else
        install_create_file(config_files, paths)
      end
    end
  end

  def do_application_rb
    filename = 'config/application.rb'
    install_insert_into_file filename, platform_config.application_rb, indent: '    ', after: 'class Application < Rails::Application'
  end

  def do_routes
    filename = 'config/routes.rb'
    install_template(filename)  if framework?
    routes = platform_config.route_concerns
    routes.push "concern :#{platform_name}, Totem::Core::Routes::Engines.new(platform_name: '#{platform_name}'); concerns [:#{platform_name}]"
    routes.unshift "\n\n  # ### #{platform_name} ### #"
    routes     = routes.join("\n  ") + "\n"
    root_route = platform_config.route_root
    inside @app_path do
      if root_route
        root_route = "  #{root_route}  # added by #{platform_name}\n\n"
        insert_into_file 'config/routes.rb', root_route, before: /^end/, verbose: verbose_copy?
      end
      insert_into_file filename, routes, before: /\s*root to:/, verbose: verbose_copy?
    end
  end

  def do_inflections
    filename        = 'config/initializers/inflections.rb'
    add_inflections = platform_config.inflections
    unless add_inflections.empty?
      inflections = ["\n# ### added by #{platform_name} ### #"]
      inflections.push 'ActiveSupport::Inflector.inflections do |inflect|'
      inflections += add_inflections.collect {|i| "  inflect.#{i.to_s.strip}"}
      inflections.push 'end'
      inflections = inflections.join("\n")
      install_append_file(filename, inflections)
    end
  end

  #
  # ### DO-Platform Gemfile Methods ### #
  #

  def do_gemfile_platform
    content  = get_platform_gems.join("\n")
    filename = "Gemfile_#{platform_name}.rb"
    install_create_file(filename, content)
    gemfile_eval = "\neval(File.read(File.dirname(__FILE__) + '/#{filename}'))"
    inside @app_path do
      append_file 'Gemfile', gemfile_eval, verbose: verbose_copy?
    end
  end

  def get_platform_gems
    gems = platform_config.platform_gems
    gems.push('') # add blank line
    platform_config.packages.each do |hash|
      pkg_spec   = hash[:pkg_spec]
      version    = vendor? || pkg_spec.blank? ? platform_config.gemspec_version : pkg_spec.version # if vendor?, the #{platform}_VERSION file is from the base spec
      package    = hash[:package]
      path       = hash[:path]
      additional = hash[:additional] || ''
      path       = File.dirname(path) if base_gem?(package)
      gems.push "gem '#{package}', '#{version}', path: '#{path}'#{additional}"
    end
    gems
  end

  #
  # ### DO-Package-Support Methods ### #
  #

  def do_gem_package
    vendor_path = platform_config.vendor_path
    stop_run "Gem package destination path #{vendor_path.inspect} is an absolute path."  if absolute_path?(vendor_path)
    unless pretend?
      say_message "Removing vendor gem directory #{File.join(@app_path, vendor_path).to_s.inspect}", :yellow
      inside @app_path do
        ::FileUtils.rm_rf(vendor_path)  # remove the vendor package directory to get fresh re-load
      end
    end
    copy_gem_package_files(platform_config.packages, vendor_path)
  end

  def copy_gem_package_files(packages, destination_path)
    pkgs = Array.wrap(packages)
    max  = pkgs.map {|h| h[:package].to_s.length}.max + 2
    pkgs.each do |hash|
      pkg         = hash[:package]
      pkg_spec    = hash[:pkg_spec]
      source_path = hash[:source_path]
      path        = hash[:path]
      stop_run "Package #{pkg.inspect} gemspec is missing in directory #{source_path.inspect}."  if pkg_spec.blank?
      stop_run "Package #{pkg.inspect} path is blank."  if path.blank?
      spec_name = pkg_spec.name
      stop_run "Package #{pkg.inspect} gemspec name is blank."  if spec_name.blank?
      dest = base_gem?(pkg) ? destination_path : File.join(destination_path, pkg) # don't add pkg if is base gem
      stop_run "Package destination path #{dest.inspect} is an absolute path."  if absolute_path?(dest)
      spec_files = pkg_spec.files
      say_message "Packaging #{spec_name.to_s.ljust(max, '.')} to #{File.join(@app_path, dest).to_s.inspect} (#files: #{spec_files.length})", :cyan
      inside @app_path do
        spec_files.each do |file|
          source_file      = File.join(source_path, file).to_s
          destination_file = File.join(dest, file).to_s
          if File.directory?(source_file)
            empty_directory destination_file, verbose: verbose_copy?  unless File.directory?(destination_file)
          else
            copy_file source_file, destination_file, verbose: verbose_copy?
          end
        end
      end
    end
  end

  # Copy the entire third-party package since a package may not have all of the files listed (or uses git to collect the files).
  def do_vendor_package
    src  = platform_config.source_vendor_path
    dest = platform_config.vendor_path
    stop_run "Vendor package destination path #{dest.inspect} is an absolute path."  if absolute_path?(dest)
    if File.exist?(src) && File.directory?(src)
      packages = Dir.entries(src).select {|f| not Dir.exist?(f)}
      return if packages.blank?
      packages.each do |pkg|
        unless pretend?
          pkg_src  = File.join(src.dup, pkg)
          pkg_dest = File.join(dest.dup, 'vendor', pkg)
          inside @app_path do
            say_message "Removing vendor package directory #{File.join(@app_path, pkg_dest).to_s.inspect}.", :yellow
            ::FileUtils.rm_rf(pkg_dest)  # remove the directory entries to get fresh re-load
            say_message "Coping vendor package #{pkg.inspect}:\n  From: #{pkg_src.to_s}\n  To:   #{File.join(@app_path, pkg_dest).to_s}", :green
            directory pkg_src, pkg_dest, verbose: verbose_copy?
          end
        end
      end
    end
  end

  def base_gem?(pkg); platform_config.gemspec_name == pkg; end

  #
  # ### DO-Secrets-Support Methods ### #
  #

  def do_secrets
    filename = 'config/secrets.yml'
    secrets  = platform_config.secrets
    return if secrets.blank?
    install_create_file 'config/secrets.yml', secrets.deep_stringify_keys.to_yaml
  end

  #
  # ### DO-Abilities Methods ### #
  #

  def do_abilities
    paths = platform_config.ability_paths
    return if paths.blank?
    array = vendor? ? package_ability_files(paths) : get_ability_local(paths)
    return if array.blank?
    hash = {classes: array}
    filename = "config/totem/#{platform_name}.abilities.yml"
    install_create_file(filename, hash.to_yaml)
  end

  def get_ability_local(paths)
    array = Array.new
    src   = platform_config.run_options_file || ''
    paths.each do |path|
      array.push(path: path, source: src)
    end
    array
  end

  def package_ability_files(paths)
    vendor_path = platform_config.vendor_path
    dest        = "#{platform_name}-authorization/app/concerns/#{platform_name}/authorization"
    dest        = File.join(vendor_path, dest)
    array       = Array.new
    inside @app_path do
      stop_run "Abilities destination #{File.join(@app_path, dest).to_s.inspect} is not a directory."   unless File.directory?(dest)
    end
    dest          = File.join(dest, 'ability_files')
    ability_files = Hash.new
    paths.each do |from_path|
      inside from_path do
        files = Dir.glob('**/*.rb').select {|f| File.file?(f)}
        files = files.map {|f| File.join(from_path, f)}
        files.each do |file|
          filename                = File.basename(file)
          from_file               = File.join(from_path, filename)
          to_file                 = File.join(dest, filename)
          ability_files[filename] = {to_file: to_file, from_file: from_file}
        end
      end
    end
    keys = ability_files.keys.sort
    keys.each do |key|
      hash      = ability_files[key]
      from_file = hash[:from_file]
      to_file   = hash[:to_file]
      install_copy_file from_file, to_file
    end
    src = platform_config()
    [{path: dest, source: platform_config.relative_run_options_file || ''}]
  end

  #
  # ### Common Thor File Actions with Status Message ### #
  #

  def install_insert_into_file(filename, content, options={})
    return if content.blank?
    message = "Inserting into #{filename.inspect}"
    say_message message, :blue
    options[:verbose] = verbose_copy?  unless options.has_key?(:verbose)
    indent = options.delete(:indent) || '  '
    if content.kind_of?(Array)
      content = content.join("\n#{indent}") + "\n\n"
    end
    inside @app_path do
      insert_into_file filename, content, options
    end
  end

  def install_append_file(filename, content)
    return if content.blank?
    message = "Appending to #{filename.inspect}"
    say_message message, :blue
    content = content.join("\n") if content.kind_of?(Array)
    inside @app_path do
      append_file filename, content, verbose: verbose_copy?
    end
  end

  def install_create_file(filename, content)
    message = "Installing #{filename.inspect}"
    say_message message, :blue
    inside @app_path do
      create_file filename, content, verbose: verbose_copy?
    end
  end

  def install_copy_file(source, destination)
    message = "Coping #{source.inspect} to #{destination.inspect}"
    say_message message, :blue
    inside @app_path do
      copy_file source, destination, verbose: verbose_copy?
    end
  end

  def install_template(filename)
    message = "Installing #{filename.inspect}"
    say_message message, :blue
    inside @app_path do
      source_file = File.join(TEMPLATE_DIRECTORY, filename).to_s
      template source_file, filename, verbose: verbose_copy?
    end
  end

  def install_remove_file(filename)
    message = "Removing  #{filename.inspect}"
    say_message message, :blue
    inside @app_path do
      remove_file filename, verbose: verbose_copy?
    end
  end

  def install_platform_template(filename)
    content = platform_config.template(filename)
    if content.blank?
      install_template(filename) if platform_config.source_template?(filename)
    else
      install_create_file(filename, content)
    end
  end

  #
  # ### Helpers ### #
  #

  def template_content; "  # No #{platform_name} template content."; end # default <%=template_content%> value

  def file_exists_in_app_path?(filename)
    file_exists = nil
    inside @app_path do
      file_exists = File.exist?(filename)
    end
    file_exists
  end

end; end; end; end
