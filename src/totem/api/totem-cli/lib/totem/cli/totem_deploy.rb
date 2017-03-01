require File.expand_path('../totem_app', __FILE__)

module Totem; module Cli; class TotemDeploy < ::Totem::Cli::TotemApp

  # Thor runs all 'public' instance methods in a class.
  # Alias the 'TotemApp#process' method and make private (so can call when run options :app is true)
  # and not automatically run by Thor. TotemDeploy has its own 'process' method.
  private :process
  alias_method :totem_app_process, :process

  class_option :api, type: :boolean, default: false, aliases: '', group: :totem_deploy,        desc: 'deploy the api specified in config'
  class_option :client, type: :boolean, default: false, aliases: '', group: :totem_deploy,     desc: 'deploy the client specified in config'

  class_option :app, type: :boolean, default: false, aliases: '', group: :totem_deploy,        desc: 'deploy framework and platform into existing Rails app'
  class_option :db_install, type: :boolean, default: false, aliases: '', group: :totem_deploy, desc: 'rake totem:db:install:all'

  class_option :promote_revision, type: :boolean, default: false, aliases: '', group: :totem_deploy, desc: 'promote the ember revision to current'

  class_option :commit, type: :boolean, default: false, aliases: '', group: :totem_deploy,     desc: 'git add -A, git add -u, git commit -m “Deployment of version X.”'
  class_option :branch, type: :string, default: 'master', aliases: '-b', group: :totem_deploy, desc: 'git branch for push'
  class_option :push, type: :boolean, default: false, aliases: '', group: :totem_deploy,       desc: 'git push origin branch'

  def process
    deploy_verify_existing_rails_app
    if perform?(:api)
      deploy_app            if perform?(:app)
      deploy_db_install     if perform?(:db_install)
      deploy_app_git_commit if perform?(:commit)
      # deploy_git_push       if run_options[:push] # currently, do not run as part of --all; require --push option (and optional --branch)
    end
    if perform?(:client)
      deploy_ember
    end
  end

  private

  def deploy_verify_existing_rails_app
    run_options[:new] = true if onew? # allow override of run options :new if use --new on the command line
    stop_run "You must deploy into an existing Rails application.  #{@app_path.inspect} is not a Rails application."  if !new? && !rails_application_exists?
  end

  def run_options_key; {key: :deploy_run_options, app: true}; end

  def deploy_app
    totem_app_process
    deploy_git_init if new?
  end

  def deploy_db_install
    cmd = "rails totem:db:install:all"
    validate_deploy_rails_app(cmd)
    say_message "Running #{cmd.inspect}.", :cyan
    debug cmd.inspect
    inside @app_path do
      run cmd, capture: capture_output?, verbose: verbose_copy?
    end
  end

  def deploy_app_git_commit
    validate_deploy_rails_app('git commit')
    message = "Deployment of: #{deploy_framework_commit_message}.  #{deploy_platform_commit_message}."
    say_message "Local commit #{message.inspect}."
    deploy_git_init
    inside @app_path do
      cmd = 'git add -A'
      say_message "Running #{cmd.inspect}.", :cyan
      rc = run cmd, verbose: verbose_copy?
      deploy_command_failure(cmd, rc)
      cmd = 'git add -u'
      say_message "Running #{cmd.inspect}.", :cyan
      rc = run cmd, verbose: verbose_copy?
      deploy_command_failure(cmd, rc)
      cmd = "git commit -m '#{message}' --quiet"
      say_message "Running #{cmd.inspect}.", :cyan
      rc = run cmd, verbose: verbose_copy?
      deploy_command_failure(cmd, rc)
    end
  end

  def deploy_git_init
    return if rails_git?  # check if already git repo
    inside @app_path do
      cmd = 'git init'
      say_message "Running #{cmd.inspect}.", :cyan
      rc = run cmd, verbose: verbose_copy?
      deploy_command_failure(cmd, rc)
    end
  end

  def deploy_ember
    say_message      "Running ember deploy."
    ember_run_options = run_options[:ember_run_options]
    application_path  = ember_run_options[:app_path]
    sha_length        = ember_run_options[:sha_length] || 7
    stop_run         "Running an Ember deploy requires an existing Ember application."  if application_path.blank?
    stop_run         "Running an Ember client deploy requires an environment specified for the deploy.js" unless run_options[:environment].present?
    cmd = "ember deploy --environment #{run_options[:environment]}"
    inside application_path do
      rc             = run cmd, capture: true, verbose: true
      revision_match = "revision: [a-zA-Z\\d]{#{sha_length}}" # e.g. match to - revision: abc1234
      revision       = rc.match(/#{revision_match}/)
      stop_run       "No revision found for #{cmd}.  Has there been changes since the last run to the client code?" unless revision.present?
      revision       = revision.to_s.last(sha_length)
      deploy_ember_promote_revision(revision)
    end
  end

  def deploy_ember_promote_revision(revision)
    # NOTE: Requires that this is already inside the application_path.
    cmd = "ember deploy:activate --revision #{revision} --environment #{run_options[:environment]}"
    if run_options[:promote_revision] # outside of the scope of 'all'
      rc         = run cmd, capture: true, verbose: true
      successful = rc.include?('Activation successful!')
      stop_run "Ember deploy command [#{cmd}] was not successful." unless successful
    else
      say_message "To promote to current: #{cmd}"
    end
  end

  # def deploy_git_push
  #   validate_deploy_rails_app('git push')
  #   branch = run_options[:branch]
  #   stop_run "A git push branch is required."  if branch.blank?
  #   cmd = "git push origin #{branch}"
  #   stop_install unless yes? "Do you want to run #{cmd.inspect} [yes|no]?", :yellow
  #   say_message "Running #{cmd.inspect}."
  #   inside @app_path do
  #     rc = run cmd, verbose: verbose_copy?
  #     deploy_command_failure(cmd, rc)
  #   end
  # end

  # ### Helpers

  def deploy_command_failure(cmd, rc=nil)
    return if rc == true
    stop_run "Command #{cmd.inspect} failure.  Install stopped."
  end

  def deploy_platform_commit_message
    hash = get_platform_run_options
    get_deploy_version_message(hash, 'Platform')
  end

  def deploy_framework_commit_message
    hash = get_framework_run_options
    get_deploy_version_message(hash, 'Framework')
  end

  def get_deploy_version_message(hash, type)
    stop_run "#{type} run options is not a hash." unless hash.is_a?(Hash)
    path = hash[:platform]
    stop_run "#{type} run options platform path is blank." if path.blank?
    version = ''
    inside path do
      file = Dir['*_VERSION'].first
      stop_run "#{type} VERSION file not found."  if file.blank? || !File.file?(file)
      version = File.read(file)
    end
    "#{type} #{path.inspect} version #{version.strip.chomp.inspect}"
  end

  def validate_deploy_rails_app(cmd)
    stop_run "#{@app_path.inspect} must be a Rails application to run #{cmd.inspect}."  unless rails_application_exists?
  end

  def self.banner
    usage = <<USAGE

#{basename} APP_PATH [options]
#{doc_banner_run_options}
USAGE
    usage
  end

end; end; end
