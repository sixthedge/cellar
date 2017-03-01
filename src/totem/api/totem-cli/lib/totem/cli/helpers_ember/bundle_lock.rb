module Totem; module Cli; module HelpersEmber; module BundleLock

  def bundle_lock_data
    @bundle_lock_data ||= begin
      if bundle? || bundle_lock_versions?
        local = get_bundle_lock_data_from_content(read_local_bundle_lock_file)
        repo  = get_bundle_lock_data_from_content(read_repo_bundle_lock_file)
        local = local.is_a?(Hash) ? local.deep_symbolize_keys : Hash.new
        repo  = repo.is_a?(Hash)  ? repo.deep_symbolize_keys  : Hash.new
        data  = local.deep_merge(repo) # repo has priority
      else
        data = Hash.new
      end
      data
    end
  end

  def get_bundle_lock_node_packages;  bundle_lock_data[:node]  || Hash.new; end
  def get_bundle_lock_bower_packages; bundle_lock_data[:bower] || Hash.new; end

  def get_bundle_lock_node_package(pkg);  get_bundle_lock_node_packages[pkg]  || Hash.new; end
  def get_bundle_lock_bower_package(pkg); get_bundle_lock_bower_packages[pkg] || Hash.new; end

  def get_package_bundle_lock_node_version(pkg);  get_bundle_lock_node_package(pkg)[:version]; end
  def get_package_bundle_lock_bower_version(pkg); get_bundle_lock_bower_package(pkg)[:version]; end

  def get_bundle_lock_data_from_content(content)
    return Hash.new  if content.blank?
    YAML.load(content)
  end

  def get_bundle_lock_filename; 'bundle.lock.yml'; end

  def get_bundle_lock_file_dir
    dir = File.dirname(run_options[:run_options_filename] || '')
    stop_run "Bundle lock file path #{dir.inspect} is not a directory."  unless File.directory?(dir)
    dir
  end

  def read_local_bundle_lock_file
    filename = get_bundle_lock_filename
    content  = nil
    inside @app_path do
      if File.file?(filename)
        content = File.read(filename)
        say set_color("    Using LOCAL bundle lock file #{File.join(@app_path, filename)}", :green, :bold)
      end
    end
    content
  end

  def read_repo_bundle_lock_file
    filename = get_bundle_lock_filename
    run_file = run_options[:run_options_file]
    return nil if run_file.blank?
    path = File.dirname(run_file)
    file = File.join(path, filename)
    return nil unless File.file?(file)
    say set_color("    Using REPO  bundle lock file #{file}", :green, :bold)
    File.read(file)
  end

  def generate_bundle_lock_file_content
    bower    = Hash.new
    node     = Hash.new
    commands = get_bundle_standardized_run_commands
    commands.each do |pkg, hash|
      base = hash.slice(:version, :command_file)
      ver  = hash[:version]
      if hash[:installed_node]
        node[pkg] = base.dup
        adjust_bundle_lock_command_filename(node[pkg])
        node[pkg].merge!(version: hash[:installed_node_version])  if ver.blank?
        (hash[:bower_related] || Array.new).each do |bpkg, bhash|
          bower[bpkg] = base.merge(bhash.slice(:version, :command_file))  unless bower.has_key?(bpkg)
          adjust_bundle_lock_command_filename(bower[bpkg])
        end
        (hash[:node_related] || Array.new).each do |npkg, nhash|
          node[npkg] = base.merge(nhash.slice(:version, :command_file))  unless node.has_key?(npkg)
          adjust_bundle_lock_command_filename(node[npkg])
        end
      end
      if hash[:installed_bower]
        bower[pkg] = base.dup
        bver       = hash[:installed_bower_version]
        case
        when ver.blank?
          bower[pkg].merge!(version: bver)
          adjust_bundle_lock_command_filename(bower[pkg])
        when ver != bver && ver.match('lts')
          bower[pkg].merge!(lts_version: ver)
          bower[pkg].merge!(version: bver)
          adjust_bundle_lock_command_filename(bower[pkg])
        end
      end
    end
    sorted_bower = Hash.new
    sorted_node  = Hash.new
    bower.keys.sort.each {|k| sorted_bower[k] = bower[k]}
    node.keys.sort.each  {|k| sorted_node[k] = node[k]}
    {node: sorted_node, bower: sorted_bower}
  end

  def adjust_bundle_lock_command_filename(hash)
    return unless hash.is_a?(Hash)
    cmd_file = hash[:command_file]
    return if cmd_file.blank? || run_dir_pwd.blank?
    hash[:command_file] = File.basename(cmd_file, '.*')
  end

end; end; end; end
