module Totem; module Cli; module HelpersApp; class PlatformConfig
  include Thor::Shell  # provides ask/say methods

  include Helpers::Package

  attr_reader :spec, :spec_path
  attr_reader :run_options
  attr_reader :erb

  def initialize(options={})
    @spec        = options[:spec]
    @spec_path   = options[:spec_path]
    @run_options = options[:run_options]
    say "Platform config #{spec.name.inspect} initialized.", :green
  end

  def framework?;   package_config[:is_framework] == true; end
  def package?;     run_options[:package] == true; end
  def deploy?;      run_options[:deploy] == true; end
  def vendor?;      package? || deploy?; end

  def gemspec_name; spec.name; end
  alias :platform_name :gemspec_name

  def gemspec_version; spec.version; end

  def run_options_file;     run_options[:run_options_file]; end
  def app_root;             run_options[:app_root]; end
  def platform_path;        run_options[:platform_path]; end
  def package_vendor_path;  run_options[:package_vendor_path]; end
  def package_config;       run_options[:current_package]; end
  def platform_config;      run_options[:current_config]; end
  def src_paths;            run_options[:src_paths]; end
  def config_paths;         run_options[:config_paths]; end
  def ability_paths;        run_options[:ability_paths]; end
  def template_paths;       run_options[:template_paths]; end
  def template_dir;         run_options[:template_dir]; end

  def route_root;     package_config[:route_root]; end
  def route_concerns; package_config_array(:route_concerns); end
  def inflections;    package_config_array(:inflections); end
  def application_rb; ["\n"] + package_config_array(:application_rb); end

  def platform_config_to_yaml; platform_config.to_yaml; end

  def relative_run_options_file; @_relative_run_options_file ||= relative_path(run_options_file); end
  def relative_platform_path;    @_relative_pathform_path    ||= relative_path(platform_path); end

  def package_config_array(key); make_array(package_config[key]); end

  def make_array(array); Array.wrap(array).compact; end

  def relative_path(path, root=app_root)
    path = Pathname.new(path)
    root = Pathname.new(root)
    path.relative_path_from(root).to_s
  end

  def vendor_path
    "vendor/totem/" + (package_vendor_path.blank? ? gemspec_name : package_vendor_path) + "-#{gemspec_version}"
  end

  # ###
  # ### Config Packages.
  # ###

  # Platform config path array options:
  #   - path:  my_dir/my_path                  #=> will find first scr_path where package exists and use File(src_dir, path)
  #   - {path: my_dir/my_path src: myrepo/api} #=> will use File.join(src, path)
  def packages
    @_packages ||= begin
      gems = Array.new
      get_package_paths.each do |hash|
        src         = hash[:src]
        pkg         = hash[:pkg]
        source_path = src.blank? ? find_src_directory(pkg) : get_absolute_path(src)
        if source_path.blank?
          say "\n[WARNING] Package #{pkg.to_s.inspect} was not found in any source path and will be skipped.\n\n", :yellow, :bold
          next
        end
        path = vendor? ? File.join("./#{vendor_path}", pkg) : source_path.dup
        gems.push gem_package(pkg, source_path, path)
      end
      gems
    end
  end

  def get_package_paths
    paths = package_config[:packages].blank? ? platform_config[:paths] : package_config[:packages]
    paths = make_array(paths)
    paths = add_base_package(paths)
    paths = paths.map {|p| p.deep_dup.merge(pkg: p[:path].gsub('/','-').gsub('_', '-'))}
    paths.sort_by {|p| p[:pkg]}
  end

  def add_base_package(paths)
    return paths if paths.find {|p| p[:path] == gemspec_name}
    [{path: gemspec_name, src: spec_path}] + paths
  end

  def gem_package(pkg, source_path, path)
    pkg_spec = get_package_spec(source_path)
    {package: pkg, path: path, source_path: source_path, pkg_spec: pkg_spec}
  end

  def get_package_spec(source_path)
    pkg_spec = nil
    Dir.chdir(source_path) do
      filename = Dir['*.gemspec'].first
      pkg_spec = Gem::Specification.load(filename) if filename.present?
    end
    pkg_spec
  end

  def secrets
    hash      = package_config[:secrets]
    variables = package_config[:variables]
    new_erb.erb_hash(hash, variables)
  end

  # ###
  # ### Platform Config Gems (e.g. 'gemfile' key).
  # ###

  def source_vendor_path; "#{spec_path}/vendor"; end

  # Gem line can use:
  #  - "gem '<%=vendor_path%>/xxxxxxxxxx'"
  def platform_gems
    array = package_config[:gemfile]
    return [] if array.blank?
    path = vendor? ? "./#{vendor_path}/vendor" : source_vendor_path
    new_erb.erb_array(array, vendor_path: path)
  end

  # ###
  # ### Platform Templates.
  # ###

  def source_template?(filename)
    return false if template_dir.blank? || filename.blank?
    file = File.join(template_dir, filename + '.tt')
    File.file?(file)
  end

  def template(filename)
    tt_file    = File.join(template_dir, filename).to_s + '.tt'
    tt_content = File.file?(tt_file) ? File.read(tt_file) : nil
    file       = find_src_file(filename, src_paths: template_paths)
    return nil if file.blank?
    return nil unless File.file?(file)
    content = File.read(file)
    return content if tt_content.blank?
    new_erb.erb_text(tt_content, platform_name: platform_name, template_content: content)
  end

  def new_erb; Helpers::PlatformErb.new(self); end

end; end; end; end
