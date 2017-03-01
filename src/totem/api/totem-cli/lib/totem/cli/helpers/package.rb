module Totem; module Cli; module Helpers;  module Package

  def get_merged_package_hash(options={})
    files = options[:package_files]
    return {} if files.blank? && options[:required] == false
    stop_run "Run options package files are blank." if files.blank?
    stop_run "Run options package files is not an array." unless files.is_a?(Array)
    merge_config_file_hashes(files)
  end

  def get_merged_platform_hash(options={})
    files = options[:config_files]
    return {} if files.blank? && options[:required] == false
    stop_run "Run options platform config files are blank." if files.blank?
    stop_run "Run options platform config files is not an array." unless files.is_a?(Array)
    validate_config_files_in_paths(files, run_options[:config_paths])
    merge_config_file_hashes(files)
  end

  def merge_config_file_hashes(files)
    hash = Hash.new
    files.each do |file|
      file_hash = get_yml_file_hash(file)
      hash.deep_merge!(file_hash)
    end
    hash
  end

  def validate_config_files_in_paths(files, paths)
    config_paths = [paths].flatten.compact
    return if config_paths.blank?
    config_paths.each do |path|
      Dir.chdir path do
        Dir.glob('*.config.yml').each do |file|
          file = File.join(path, file)
          stop_run "Config file #{file.inspect} is not included -- but is in directory #{path.inspect} and totem will use all config files in the directory." unless files.include?(file)
        end
      end
    end
  end

  def get_yml_file_hash(file)
    file = get_absolute_path(file)
    stop_run "Run options config package file #{file.inspect} is not a file."  unless File.file?(file)
    content = File.read(file)
    hash    = YAML.load(content)
    return {} if hash.blank?
    stop_run "Run options package file [#{file.inspect}] is not a hash."  unless hash.is_a?(Hash)
    hash.deep_symbolize_keys
  end

  def find_src_file(pattern, options=run_options); find_src_files(pattern, options).first; end

  def find_src_files(pattern, options=run_options)
    files = []
    paths = options[:src_paths] || []
    paths.each do |path|
      find_pattern  = File.join(path, pattern)
      files        += Dir[find_pattern].select {|f| File.file?(f)}
    end
    files
  end

  def find_src_directory(pattern, options=run_options); find_src_directories(pattern, options).first; end

  def find_src_directories(pattern, options=run_options)
    dirs  = []
    paths = options[:src_paths] || []
    paths.each do |path|
      find_pattern = File.join(path, pattern)
      dirs        += Dir[find_pattern].select {|d| File.directory?(d)}
    end
    dirs
  end

  def get_run_options_yml_filename(filename)
    File.extname(filename) == '.yml' ? filename : filename + '.yml'
  end

  def get_run_option_path_and_name(path)
    path.match(/\//) ? [File.dirname(path), File.basename(path)] : ['.', path]
  end

  def get_absolute_path(path, file=nil)
    path = File.join(path) if path.is_a?(Array)
    file = File.join(file) if file.is_a?(Array)
    case
    when absolute_path?(path) && file.blank?    then path
    when file.present? && absolute_path?(file)  then file
    when absolute_path?(path) && file.present?  then File.expand_path(file, path)
    when file.blank?                            then File.expand_path(path, run_dir_pwd)
    else                                             File.expand_path(File.join(path, file), run_dir_pwd)
    end
  end

  def absolute_path?(dir)
    Pathname.new(dir).absolute?
  end

  def relative_path(dir, from_dir)
    return nil if dir.blank? || from_dir.blank?
    case
    when  absolute_path?(dir) &&  absolute_path?(from_dir)
    when !absolute_path?(dir) && !absolute_path?(from_dir)
    else
      return nil
    end
    Pathname.new(dir.to_s).relative_path_from(Pathname.new(from_dir.to_s)).to_s
  end

end; end; end; end
