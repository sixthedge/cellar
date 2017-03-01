module Totem; module Cli; module Helpers;  module RunOptions

  def self.included(base)
    return unless base.ancestors.include?(Thor::Group)
    base.class_eval do
      class_option :run_options_file, type: :string, default: nil, aliases: '-o', desc: 'run options file'
    end
  end

  attr_reader :run_options
  attr_reader :run_dir_pwd

  def app?; @_app; end

  def initialize_run_options_and_merge_run_options_file(opts={})
    @run_dir_pwd = Dir.pwd
    @run_options = options.dup.deep_symbolize_keys  # dup since options hash is frozen
    merge_run_options_file(opts)
    @_app      = opts[:app] || false
    set_standard_run_options if app?
  end

  def merge_run_options_file(opts)
    file = run_options[:run_options_file]
    return if file.blank?
    file = File.join(run_dir_pwd, file)
    file = get_run_options_yml_filename(file)
    run_options[:run_options_file] = file
    stop_run "Run options file: #{file.inspect} does not exist."  unless File.exists?(file)
    say_message set_color("Running with options file ", :green) + set_color(file, :green, :bold)
    run_options[:run_options_key] = opts[:key]
    hash     = get_yml_file_hash(file)
    key_hash = get_options_key_hash(hash, opts)
    run_options.merge!(key_hash)
  end

  def get_options_key_hash(hash, opts)
    key = run_options[:run_options_key]
    return hash.deep_symbolize_keys if key == false
    stop_run "Run options has a blank key value."  if key.blank?
    stop_run "#{key.inspect} is not a key in the run options file."  unless (opts[:required] == false || hash.has_key?(key))
    run_hash = hash[key] || Hash.new
    stop_run "Run options key #{key.inspect} is not a hash." unless run_hash.is_a?(Hash)
    run_hash.deep_symbolize_keys
  end

  def set_standard_run_options
    run_options[:framework_run_options] = get_standard_framework_run_options
    run_options[:platform_run_options]  = get_standard_platform_run_options
  end

  def get_standard_framework_run_options(options=get_framework_run_options)
    type = 'Framework'
    options.deep_merge get_options_run_options(options, type)
  end

  def get_standard_platform_run_options(options=get_platform_run_options)
    type = 'Platform'
    options.deep_merge get_options_run_options(options, type)
  end

  def get_merged_standard_framework_package
    options = get_standard_framework_run_options
    get_merged_package_hash(options.merge(required: false))
  end

  def get_merged_standard_platform_package
    options = get_standard_platform_run_options
    get_merged_package_hash(options.merge(required: false))
  end

  def get_merged_framework_config
    options = get_framework_run_options
    get_merged_platform_hash(options)
  end

  def get_merged_platform_config
    options = get_platform_run_options
    get_merged_platform_hash(options)
  end

  def get_options_run_options(options, type='')
    stop_run "#{type} config run options are blank." if options.blank?
    {
      platform_name:  get_options_platform_name(options, type),
      platform_path:  get_options_platform_path(options, type),
      src_paths:      get_options_paths(options, type, :src_paths),
      ability_paths:  get_options_paths(options, type, :ability_paths, false),
      package_files:  get_options_files(options, type, :package_files),
      config_files:   get_options_files(options, type, :config_files),
      config_paths:   get_options_paths_from_files(options, type, :config_files),
      template_paths: get_options_paths(options, type, :template_paths, false),
    }
  end

  def get_framework_run_options(options=run_options); options[:framework_run_options]; end
  def get_platform_run_options(options=run_options);  options[:platform_run_options];  end

  def get_options_platform_name(options, type='')
    name = options[:platform_name] || options[:platform]
    stop_run "#{type} platform name is blank.", :red   if name.blank?
    name
  end

  def get_options_platform_path(options, type='')
    path = options[:platform]
    stop_run "#{type} platform path is blank.", :red   if path.blank?
    get_absolute_path(path)
  end

  def get_options_paths(options, type, key, required=true)
    paths = [options[key]].flatten.compact
    stop_run "#{type} #{key} are blank.", :red   if paths.blank? && required
    array = Array.new
    paths.each do |p|
      path = get_absolute_path(p)
      stop_run "#{type} #{key} #{path.inspect} is not a directory.", :red unless File.directory?(path)
      array.push(path)
    end
    array
  end

  def get_options_files(options, type, key, required=true)
    files = [options[key]].flatten.compact
    stop_run "#{type} #{key} are blank.", :red   if files.blank? && required
    array = Array.new
    files.each do |f|
      file = get_absolute_path(f)
      stop_run "#{type} #{key} #{file.inspect} is not a file.", :red unless File.file?(file)
      array.push(file)
    end
    array
  end

  def get_options_paths_from_files(options, type, key)
    files = get_options_files(options, type, key)
    paths = files.map {|f| File.dirname(f)}
    paths.each do |path|
      stop_run "#{type} #{key} #{path.inspect} is not a directory.", :red unless File.directory?(path)
    end
    paths
  end

end; end; end; end
