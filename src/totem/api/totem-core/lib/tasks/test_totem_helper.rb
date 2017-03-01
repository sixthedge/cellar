require 'rake/testtask'

module TestTotemHelper

  def totem_get_options(args, options={})
    options[:engine_name] = args.engine_name
    list_files       = true  # default
    list_dirs        = false # default
    list_helper_dirs = false # default
    path             = Array.new
    [args.extras].flatten.compact.each do |arg|
      case arg.downcase
      when 'nf', 'no_file_list', 'no-file-list'     then list_files       = false
      when 'd', 'dir_list', 'dir-list'              then list_dirs        = true
      when 'h', 'helper_list', 'helper-list'        then list_helper_dirs = true
      else
        path.push(arg)
      end
    end
    options[:list_files]        = list_files
    options[:list_dirs]         = list_dirs
    options[:list_helper_dirs]  = list_helper_dirs
    options[:path]              = path
    options
  end

  def totem_all_test_task(options={})
    match_name = options[:engine_name]
    error "No engine pattern match provided for 'all' task."  if match_name.blank?
    test_files = Array.new
    libs       = Array.new
    totem_engines.each do |engine|
      next unless engine.engine_name.start_with?(match_name)
      test_files += totem_get_engine_test_files(engine, options)
      libs       += totem_get_test_helper_directory(engine, options)
    end
    totem_setup_rake_test_task(test_files.sort, libs, options)
  end

  def totem_engine_test_task(options)
    name   = options[:engine_name]
    engine = totem_engines.find {|e| e.railtie_name == name}
    error "No engine matches name #{name.inspect}.  Did you use the folder name instead of the engine_name?"  if engine.blank?
    test_files = totem_get_engine_test_files(engine, options)
    libs       = totem_get_test_helper_directory(engine, options)
    totem_setup_rake_test_task(test_files.sort, libs, options)
  end

  def totem_setup_rake_test_task(test_files, libs, options)
    set_totem_test_environment_variables(options)
    totem_print_setup(test_files, libs, options)
    libs.each {|lib| $LOAD_PATH.push(lib)}  # add the helper directories to the load path
    Minitest.rake_run(test_files)
  end

  def set_totem_test_environment_variables(options)
    env     = ENV['TESTOPTS'] || ''
    verbose = env.match('-v') || env.match('--verbose')
    ENV['TOTEM_STARTUP_NO_SERIALIZERS'] = 'false'
    ENV['TOTEM_STARTUP_QUIET'] = 'true'  unless verbose
    # Path to Rails main app config/environment.rb.
    ENV['MAIN_APP_CONFIG_ENV'] = Rails.root.join('config', 'environment').to_s
    # Path to Rake::TestTask 'test_helper.rb'.
    # 'test_helper.rb' sets the test environment plus additional setup.
    # Tests need to "$:.push ENV['TOTEM_TEST_HELPER']" (to add to load path) then "require test_helper".
    ENV['TOTEM_TEST_HELPER'] = File.expand_path('../../../test', __FILE__).to_s
    if options[:unit].present?
      # Rake::Task[:test].clear # removes db:prepare task
      ENV['UNIT_TESTS'] = 'true'
    end
  end

  def totem_get_test_helper_directory(engine, options)
    dir  = File.join(engine.root, 'test')
    dirs = Dir.glob(File.join(dir, '**/helpers'))
    dirs.select {|d| File.directory?(d)}
  end

  def totem_get_engine_test_files(engine, options)
    base_path = File.join(engine.root, 'test')
    if options[:path].blank?
      path  = options[:path] = ['*']
      paths = [path]
    else
      path      = options[:path]
      dir_paths = path.deep_dup
      last_path = dir_paths.pop
      if last_path.to_s.match(':')
        paths = last_path.split(':').compact.uniq.map {|p| dir_paths + [p] + [File.directory?(File.join(base_path, p)) ? '*' : nil].compact}
      else
        path.push('*') if File.directory?(File.join(base_path, path))
        paths = [path]
      end
    end
    test_files = Array.new
    paths.each do |path|
      each_path  = path.deep_dup
      test_match = each_path.pop
      test_path  = File.join(base_path, each_path, "**/#{test_match}_test.rb")
      test_files += Dir.glob(test_path).select {|file| !file.to_s.match('test/helpers')}
    end
    test_files.uniq
  end

  def totem_engines
    ::Rails::Engine.subclasses.map(&:instance)
  end

  def totem_print_setup(test_files, libs, options)
    return if options[:print_setup] == false
    rake_cmd = ARGV.join(' ')
    totem_message "\n"
    width = 20
    totem_message '** caution: Unit tests do not perform a db:prepare **'  if options[:unit].present?
    totem_message 'Test Run Options:'
    totem_message '  run'.ljust(width) + ": rake #{rake_cmd}"
    totem_message '  coverage'.ljust(width) + ": #{options[:coverage].present?}"
    totem_message '  environment'.ljust(width) + ": #{ENV['MAIN_APP_CONFIG_ENV'].inspect}"
    totem_message '  test_helper'.ljust(width) + ": #{ENV['TOTEM_TEST_HELPER'].inspect}"
    totem_message '  options'.ljust(width) + ": #{options.inspect}"
    if options[:list_helper_dirs]
      if libs.present?
        if libs.length == 1
          totem_message "  helper lib dir".ljust(width) + ": #{libs.first}"
        else
          totem_message "  helper lib dirs (#{libs.length}):"
          libs.sort.each_with_index do |lib, index|
            totem_message "   #{(index + 1).to_s.rjust(5)}. #{lib}"
          end
        end
      end
    end
    if options[:list_dirs]
      totem_message "  test files per dir (total=#{test_files.length}):"
      file_counts = Hash.new(0)
      test_files.sort.each do |file|
        dirname = File.dirname(file)
        file_counts[dirname] += 1
      end
      file_counts.each do |dirname, count|
        s_count = "(#{count})"
        totem_message "   #{s_count.rjust(6)} -> #{dirname}"
      end
    end
    if options[:list_files]
      totem_message "  test files:"
      test_files.each_with_index do |file, index|
        totem_message "   #{(index + 1).to_s.rjust(5)}. #{file}"
      end
    end
    totem_message "\n"
  end

  def totem_message(message)
    puts message
  end

  def error(message)
    raise "#{self.class.name}: #{message}"
  end

end
