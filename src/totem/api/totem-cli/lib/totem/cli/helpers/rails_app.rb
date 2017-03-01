module Totem; module Cli; module Helpers; module RailsApp

  def self.included(base)
    return unless base.ancestors.include?(Thor::Group)
    base.class_eval do
      argument :app_path, type: :string, default: nil, required: false, desc: 'rails application path'

      add_runtime_options!

      class_option :new, type: :boolean, default: false, aliases: '',              desc: 'create a new rails application'
      class_option :deploy, type: :boolean, default: false, aliases: '',           desc: 'create a packaged vendor directory'
      class_option :package, type: :boolean, default: false, aliases: '',          desc: 'package the gems in the Rails app'
      class_option :skip_exist_check, type: :boolean, default: false, aliases: '', desc: 'stop run if rails app already exists'
    end
  end

  def rails_application_exists?
    File.exists? File.join(@app_path, 'bin', 'rails')
  end

  def rails_gem_installed?
    version = `rails --version` rescue version = nil
    version.present? ? version.sub('Rails','').strip.chomp >= rails_version : false
  end

  def rails_version
    '5.0.0'
  end

  def rails_git?
    dir = File.join(@app_path, '.git')
    File.directory?(dir)
  end

  def new_rails_app_validation
    unless rails_gem_installed?
      stop_run "Rails version #{rails_version.inspect} or greater must be installed to create a new Rails application."
    end
    unless File.exist?(@app_root)
      stop_run "#{@app_root.inspect} directory does not exist.  Please create it and run again.", :red
    end
    if File.exist?(@app_path) && !run_options[:skip_exist_check]
      stop_run "Directory #{@app_path.inspect} already exists.  Please remove it to re-create -or- provide a different app path and run again.", :red
    end
  end

  def create_rails_app
    stop_install unless yes? "Create Rails application #{@app_path.inspect}? [yes,no]", :yellow  if !quiet? && !verify?

    cmd_options = ['--skip-keeps', '--skip-bundle', '--skip-listen', '--skip-sprockets', '--skip-javascript']
    cmd_options.push run_options[:rails_api] != false   ? '--api'                   : '--no-api'  # default to true if not included
    cmd_options.push run_options[:rails_gemfile]        ? '--no-skip-gemfile'       : '--skip-gemfile'
    cmd_options.push run_options[:rails_git]            ? '--no-skip-git'           : '--skip-git'
    cmd_options.push run_options[:rails_spring]         ? '--no-skip-spring'        : '--skip-spring'
    cmd_options.push run_options[:rails_cable]          ? '--no-skip-action-cable'  : '--skip-action-cable'
    cmd_options.push run_options[:rails_cable]          ? '--no-skip-puma'          : '--skip-puma'
    cmd_options.push run_options[:rails_turbolinks]     ? '--no-skip-turbolinks'    : '--skip-turbolinks'
    cmd_options.push '--force'   if force?
    cmd_options.push '--quiet'   if quiet?
    cmd_options.push '--pretend' if pretend?
    cmd_options.push '--skip'    if skip?

    rails_cmd = "rails new #{@app_path} #{cmd_options.join(' ')}"
    say_message "Running rails command:"
    say_message "  #{rails_cmd}", :cyan, :bold
    run rails_cmd, capture: !verbose_copy?, verbose: verbose_copy?

    inside @app_path do
      ::FileUtils.rm_rf('app')
      ::FileUtils.rm_rf('db')
      ::FileUtils.rm_rf('lib')
      ::FileUtils.rm_rf('test')
    end
  end

end; end; end; end
