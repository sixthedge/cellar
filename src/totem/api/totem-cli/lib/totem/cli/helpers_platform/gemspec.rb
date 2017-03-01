module Totem; module Cli; module HelpersPlatform; module Gemspec

  def set_platform_config_with_gemspec
    setup_local_gemspec
  end

  def setup_local_gemspec
    begin
      @platform_config = get_platform_config_instance
    rescue Errno::ENOENT => e
      stop_run "Platform path directory #{name.inspect} does not exist.", :red
    end
  end

  def get_platform_config_instance
    file = find_src_file('*.gemspec')
    stop_run "Gem specification file not found in src_paths.", :red  if file.blank?
    stop_run "Gem specification file #{file.inspect} is not a file.", :red  unless File.file?(file)
    spec = Gem::Specification.load(file)
    stop_run "Gem specification could not be created for #{file.inspect}.", :red  unless spec
    HelpersApp::PlatformConfig.new(
      spec:        spec,
      spec_path:   File.dirname(file),
      run_options: run_options.deep_dup,
    )
  end

end; end; end; end
