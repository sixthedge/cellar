HELPERS_DIR = 'helpers_platform'
require File.expand_path('../helpers/require_all', __FILE__)
require File.expand_path('../helpers_app/platform', __FILE__)
require File.expand_path('../helpers_app/platform_config', __FILE__)

module Totem; module Cli; class TotemApp < Thor::Group
  include Thor::Actions

  include Helpers::RailsApp
  include Helpers::RunOptions
  include Helpers::RunHelpers
  include Helpers::Common
  include Helpers::Package
  include Helpers::Doc

  def overview_or_examples?; doc_options; end

  def prepare_options
    initialize_run_options_and_merge_run_options_file(run_options_key)
  end

  def prepare_rails_options
    set_app_path_and_app_name
  end

  def debug_options?
    verify_options_and_gemset  if verify?
    debug_run_options
  end

  def process
    do_framework
    do_platform
    do_db         if perform?(:db_name_prefix) || perform?(:db_name)
    do_bundle     if perform?(:bundle)
  end

  private

  def run_options_key; {key: :app_run_options, app: true}; end

  def perform?(key)
    run_options[key] || run_options[:all]
  end

  def do_framework
    framework = get_framework_run_options
    return if framework.blank?
    pkg    = get_merged_standard_framework_package
    config = get_merged_platform_hash(framework)
    hash   = run_options.deep_dup.merge(framework)
    hash[:current_package] = pkg
    hash[:current_config]  = config
    say_message "Installing framework #{framework[:platform_name].inspect}."
    HelpersApp::Platform.start(hash)
  end

  def do_platform
    platform = get_platform_run_options
    return if platform.blank?
    pkg    = get_merged_standard_platform_package
    config = get_merged_platform_hash(platform)
    hash   = run_options.deep_dup.merge(platform)
    hash[:current_package] = pkg
    hash[:current_config]  = config
    say_message "Installing platform #{platform[:platform_name].inspect}."
    HelpersApp::Platform.start(hash)
  end

  def do_db
    filename = 'config/secrets.yml'
    inside @app_path do
      if db_name_prefix = run_options[:db_name_prefix]
        say_message "Adding database name prefix #{db_name_prefix.inspect}."
        gsub_file filename, /name:\s+development/, "name: #{db_name_prefix}_development", verbose: verbose_copy?
        gsub_file filename, /name:\s+test/, "name: #{db_name_prefix}_test", verbose: verbose_copy?
      end
      if db_username = run_options[:db_user]
        say_message "Changing database username to #{db_username.inspect}."
        gsub_file filename, /username:\s+postgres/, "username: #{db_username}", verbose: verbose_copy?
      end
    end
  end

  def do_bundle
    say_message "Doing bundle install for #{@app_path.inspect} (this may take awhile)..."
    inside @app_path do
      run "bundle install", capture: capture_output?, verbose: verbose_copy?
    end
  end

  def self.banner
    usage = <<USAGE

#{basename} APP_PATH [options]
#{doc_banner_run_options}
USAGE
    usage
  end

end; end; end
