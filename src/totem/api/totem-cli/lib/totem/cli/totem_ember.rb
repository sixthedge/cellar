HELPERS_DIR = 'helpers_ember'
require File.expand_path('../helpers/require_all', __FILE__)
require 'json'

module Totem; module Cli; class TotemEmber < Thor::Group
  include Thor::Actions
  add_runtime_options!

  argument :app_path, type: :string, default: nil, required: false, desc: 'ember application path'

  class_option :new, type: :boolean, default: false, aliases: '',                   desc: 'create a new ember application'
  class_option :build_js, type: :boolean, default: false, aliases: '-b',            desc: 'update the ember app build file'
  class_option :unlink, type: :boolean, default: false, aliases: '-u',              desc: 'unlink modules in the app path'
  class_option :link, type: :boolean, default: false, aliases: '-l',                desc: 'add links in the app path'
  class_option :package, type: :boolean, default: false, aliases: '-k',             desc: 'update the root app path package.json dependencies with the modules'
  class_option :environment_js, type: :boolean, default: false, aliases: '-e',      desc: 'only install the app_path/config/environment.js'
  class_option :deploy_js, type: :boolean, default: false, aliases: '-d',           desc: 'install the config/deploy.js file'
  class_option :index_html, type: :boolean, default: false, aliases: '',            desc: 'install the app/index.html file'
  class_option :bundle, type: :boolean, default: false, aliases: '',                desc: 'bundle the ember application'
  class_option :create_lock_file, type: :boolean, default: false, aliases: '',      desc: 'create local ember app bundle.lock.yml file'
  class_option :run, type: :array, default: nil, aliases: '-r',                     desc: 'run one or more of command files'
  class_option :dry_run, type: :boolean, default: false, aliases: '',               desc: 'run but do not make updates'

  include Helpers::Common
  include Helpers::RunHelpers
  include Helpers::RunOptions
  include Helpers::Package
  include Helpers::Doc
  include HelpersEmber::Common
  include HelpersEmber::Versions
  include HelpersEmber::Links
  include HelpersEmber::BuildFile
  include HelpersEmber::App
  include HelpersEmber::Templates
  include HelpersEmber::Bundle
  include HelpersEmber::BundleLock

  TEMPLATE_DIRECTORY = File.expand_path('../helpers_ember/templates', __FILE__).to_s

  def overview_or_examples?; doc_options; end

  def pre_process
    self.class.source_root [TEMPLATE_DIRECTORY]
    set_run_versions
  end

  def check_pre_requisites
    stop_run "'node' must be installed on your system before running this program."  unless node_is_installed
    stop_run "'npm' must be installed on your system before running this program."   unless npm_is_installed
  end

  def prepare_options
    initialize_run_options_and_merge_run_options_file(key: :ember_run_options)
    run_options[:template_dir] = TEMPLATE_DIRECTORY
    set_ember_run_options
    set_default_new_app_options if new?
    debug_run_options
  end

  def validate_options
    ember_validate_options
    stop_install unless yes? "Node version #{installed_node_version.inspect}.  Is this correct? [yes,no]", :yellow  if verify? && !node_version
    print_dry_run_message
  end

  def process
    do_new_app              if new?
    do_bundle               if bundle?
    do_run                  if run?
    do_create_lock_file     if perform?(:create_lock_file)
    do_environment_js       if perform?(:environment_js)
    do_index_html           if perform?(:index_html)
    do_unlink               if perform?(:unlink)
    do_link                 if perform?(:link)
    do_package              if perform?(:package)
    do_build_js             if perform?(:build_js)  # do after link since may reference a linked module path
    do_deploy_js            if perform?(:deploy_js)
  end

  def post_process
    print_dry_run_message
  end

  private

  def perform?(key); run_options[key] == true; end

  def perform_any?(*keys)
    keys.each { |key| return true if perform?(key) }
    false
  end

  def run?;                  run_options[:run].present?; end
  def bundle?;               perform?(:bundle); end
  def bundle_lock_versions?; perform?(:bundle_lock_versions); end
  def bundle_uninstall?;     true; end

  def set_default_new_app_options
    run_options[:package]           = true
    run_options[:index_html]        = true
    run_options[:environment_js]    = true
    run_options[:build_js]          = true
    run_options[:unlink]            = true
    run_options[:link]              = true
    run_options[:create_lock_file]  = true
  end

  # ###
  # ### Do Command.
  # ###

  def do_environment_js; install_platform_template('config/environment.js'); end
  def do_deploy_js;      install_platform_template('config/deploy.js'); end
  def do_index_html;     install_platform_template('app/index.html', as_is_if_exists: true); end
  def do_build_js;       install_platform_template('ember-cli-build.js', imports_and_trees: get_ember_imports_and_trees); end

  def do_new_app
    create_ember_app
    filename = 'app/app.js'
    say_message "Updating #{filename.inspect}.", do_message_color
    install_template(filename)
  end

  def do_bundle
    run_commands = get_bundle_run_commands
    if run_commands.blank?
      say_message "No bundle commands to run.  All node and bower modules installed.", [do_message_color, :bold]
      new? ? return : stop_install
    end
    print_run_commands(run_commands)
    return if dry_run?
    is_yes = yes?("Run these bundle commands? [yes,no]", :yellow)
    unless is_yes
      new? ? return : stop_install
    end
    save_commands = all_commands.deep_dup  # save so can reset after bundle is complete for other perform methods
    @all_commands = run_commands
    run_ember_app_commands
    @all_commands = save_commands
  end

  def do_run
    run_list                        = (run_options[:run] || []).map {|r| {run: r}}
    @current_package                = {commands: run_list}
    @all_commands, @command_imports = get_all_commands_and_imports
    commands                        = all_commands.dup
    imports                         = command_imports.dup
    print_run_commands(all_commands)
    unless dry_run?
      is_yes = yes?("Run these commands? [yes,no]", :yellow)
      stop_install unless is_yes
    end
    run_ember_app_commands
    set_ember_run_options
    all_commands.push(*commands)
    command_imports.push(*imports)
  end

  def do_create_lock_file
    filename = get_bundle_lock_filename
    content  = generate_bundle_lock_file_content
    content  = content.deep_stringify_keys.to_yaml
    say_message "Creating LOCAL #{filename.inspect} in #{@app_path.inspect}.", do_message_color
    install_create_file(filename, content)
  end

  def do_unlink
    say_message "Unlink node modules.", do_message_color
    ember_unlink_packages
  end

  def do_link
    say_message "Link node modules.", do_message_color
    ember_link_packages
  end

  def do_package
    say_message "Update package.json.", do_message_color
    ember_update_package_json
  end

  # ###
  # ### Helpers.
  # ###

  def capture?;          !debug? && !verbose_run?; end  # capture == true means suppress output
  def verbose?;          verbose_copy?; end
  def verbose_run?;      run_options[:verbose_run].present? && !quiet?; end
  def run_message_color; :cyan; end
  def do_message_color;  :green; end

  def print_dry_run_message
    return unless dry_run?
    say_newline
    say_dry_run_message
  end

  def user_action_message(message)
    say_newline
    say_message set_color message, :on_yellow, :black
  end

  def self.banner
    usage = <<USAGE

#{basename} APP_PATH [options]
USAGE
    usage
  end

end; end; end
