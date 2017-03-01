module Totem; module Cli; module Helpers; module Common

  def self.included(base)
    return unless base.ancestors.include?(Thor::Group)
    base.class_eval do
      class_option :debug, type: :boolean, default: false, aliases: '',            desc: 'show command being run'
      class_option :verbose_copy, type: :boolean, default: false, aliases: '-V',   desc: 'verbose file copy status messages'
      class_option :verify, type: :boolean, default: false, aliases: '-v',         desc: 'print run options and ask to verify'
    end
  end

  def set_app_path_and_app_name
    app_path  = run_options[:app_path]
    @app_path = app_path if @app_path.blank? # command line argument takes priority over run_options
    stop_run "A Rails application path argument is required.", :red  if @app_path.blank?
    if @app_path.match(/\//)
      app_root = File.dirname(@app_path)
      app_name = File.basename(@app_path)
    else
      app_root = '.'
      app_name = @app_path
    end
    @app_root = run_options[:app_root] = get_absolute_path(app_root)
    @app_path = run_options[:app_path] = get_absolute_path(@app_path)
    @app_name = run_options[:app_name] = app_name
  end

  def debug(message, color=:white)
    return unless debug?
    say '[debug] ' + message, color
  end

  def debug_run_options(title=self.class.name)
    return unless debug?
    say_newline
    debug "#{title.inspect} run options:\n#{get_printable_run_options}"  if debug? && !verify?
  end

  def validate_path(*args)
    message = args.pop
    path    = File.join(*args)
    begin
      Dir.chdir(path) do
      end
    rescue Errno::ENOENT => e
      stop_run message, :red
    end
  end

  def verify_options_and_gemset(title=self.class.name)
    say "#{title.inspect} run options:\n#{get_printable_run_options}"
    say_newline
    stop_install unless yes? "Continue with the above options? [yes|no]", :yellow
  end

  def get_rvm_gemset
    return 'pretend'  if pretend?
    begin
      rc = run 'rvm gemset list', capture: true, verbose: false
    rescue Errno::ENOENT
      return nil
    end
    gemset = 'unknown'
    rc.each_line do |line|
      line.chomp!.strip!
      if line.start_with?('=>')
        gemset = line.sub('=>','').strip
      end
    end
    gemset
  end

  def say_dry_run_message
    say_message "  DRY RUN!!".ljust(80), :on_blue
    say_newline
    say_newline
  end

  def say_newline
    say ''
  end

  def say_message(*args)
    return if quiet?
    message = args.shift
    args.push(:blue)  unless args.first
    say message, *args
  end

  def stop_install
    stop_run "Install stopped.", :yellow
  end

  def stop_run(*args)
    message = args.shift || ''
    args.push(:red)  unless args.first
    say message, *args
    exit 1
  end

  def build_framework_cli
    say_message "Building #{get_framework_name.inspect} installer gem."
    cmd = "ruby install.rb --cli --package_dir '#{get_framework_package_path}' --package_filename '#{get_framework_package_filename}'"
    debug cmd.inspect
    Dir.chdir get_framework_path do
      rc = run cmd, capture: capture_output?, verbose: verbose_copy?
      stop_install  unless rc
    end
  end

end; end; end; end
