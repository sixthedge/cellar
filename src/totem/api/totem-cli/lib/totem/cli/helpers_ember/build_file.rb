module Totem; module Cli; module HelpersEmber; module BuildFile

  attr_reader :imported_files, :import_trees

  def get_ember_imports_and_trees
    imports, trees = prepare_ember_cli_build_file_changes
    indent         = '  '
    content        = ''
    if imports.blank?
      content += "\n#{indent}// **No imports**\n\n"
    else
      content += "\n#{indent}// **Imports**\n"
      imports.each {|i| content += "  #{i}\n"}
    end
    if trees.blank?
      content += "\n#{indent}// **No trees**\n\n"
    else
      content += ''
      content += "\n#{indent}// **Trees**\n"
      content += "#{indent}var pick_files = require('broccoli-funnel');\n"
      trees.each {|t| content += "#{indent}#{t}\n"}
    end
    content
  end

  def build_file_options; current_package[:ember_cli_build]; end

  def prepare_ember_cli_build_file_changes
    @imported_files = Array.new
    @import_trees   = Array.new
    imports = trees = []
    inside @app_path do
      imports = build_file_app_imports
      trees   = build_file_app_trees
    end
    [imports, trees]
  end

  # ###
  # ### Imports.
  # ###

  def auto_import?; run_options[:auto_import] != false; end  # default to true if not in run options file

  def build_file_app_imports
    before_imports = build_file_options[:import_before] || Array.new
    imports        = build_file_options[:import]        || Array.new
    stop_run "Build file app import must be an array."         unless imports.is_a?(Array)
    stop_run "Build file app import_before must be an array."  unless before_imports.is_a?(Array)
    auto_imports = Array.new
    command_imports.each do |hash|
      next unless hash.is_a?(Hash)
      file = hash[:command_file]
      name = hash[:name]
      [hash[:import]].flatten.compact.each do |import|
        stop_run "Import in file #{file.inspect} is not a hash." unless import.is_a?(Hash)
        auto_imports.push(import.merge(command_file: file, name: name))
      end
    end
    all_imports = before_imports + auto_imports + imports
    return [] if all_imports.blank?
    changes = Array.new
    add_build_file_import_changes(changes, all_imports)
    check_for_duplicate_import_files
    changes
  end

  def check_for_duplicate_import_files
    return if imported_files.blank?
    files = [imported_files].flatten.sort.collect {|file| File.basename(file)}
    dups  = files.select {|file| files.count(file) > 1}.uniq
    say_message "[warning] The following files were imported more than once #{dups.inspect}.", :yellow  if dups.present?
    if debug?
      say_message "The following files where imported:", :green
      files.each_with_index do |file, index|
        count = ((index + 1).to_s + '.').rjust(3)
        say_message "  #{count} #{file.inspect}", :green
      end
    end
  end

  def add_build_file_import_changes(changes, imports, depth=0)
    depth += 1
    stop_run "Too much build_file import recursion depth #{depth}."  if depth > 10
    imports.each do |import|
      case
      when import.kind_of?(Hash)
        add_build_file_hash_imports(changes, import, depth)
      when import.kind_of?(String)
        if import.start_with?('//')  # add comments as-is
          changes.push import
        else
          changes.push "app.import(#{import});"
        end
      else
        stop_run "Unknown build_file import change #{import.inspect}."
      end
    end
  end

  def add_build_file_hash_imports(changes, hash, depth)
    pattern = hash[:pattern]
    tree    = hash[:tree]
    import  = hash[:import]
    case
    when pattern.present? && tree.present?
      stop_run "Build file import cannot have both a 'pattern' and 'tree' #{hash.inspect}."
    when import.present? && (pattern.present? && tree.present?)
      stop_run "Build file import command cannot have 'pattern' or 'tree' #{hash.inspect}."
    when pattern.present?
      files = Dir.glob pattern
      if files.blank?
        say_message "Build file import pattern #{pattern.inspect} did not match any files.  Skipping.", :yellow unless dry_run?
      else
        # Unless :order is specified, app.import statements will be in Dir.glob order.
        files = order_build_file_import_files(files, hash)
        imported_files.push files
        add_comments_to_changes(changes, hash)
        files.each do |file|
          changes.push format_build_file_import(file, hash)
        end
      end
    when tree.present?
      import_trees.push hash
    when import.present?
      stop_run "Import configs are blank for import #{import.inspect}."  if all_configs.blank?
      config = all_configs[import]
      if config.blank?
        say_message "Import config #{import.inspect} is blank #{hash.inspect}.", :red
        stop_run "Do you mean one of these #{all_configs.keys.sort}."
      end
      imports = config[:import]
      if imports.blank?
        say_message "[WARNING] Import config #{import.inspect} import is blank.  Skipping."
      else
        stop_run "Import config #{import.inspect} import is not an array but is #{imports.class.name.inspect}."  unless imports.kind_of?(Array)
        add_build_file_import_changes(changes, imports, depth)
      end
    else
      stop_run "Build file import must have either a 'pattern' or 'file' #{hash.inspect}."
    end
  end

  def order_build_file_import_files(files, hash)
    return files unless (order = hash[:order]).present?
    file_order = Array.new
    [order].flatten.each do |basename|
      files.each {|file| file_order.push(file)  if File.basename(file) == basename}
      files -= file_order
    end
    file_order + files
  end

  def format_build_file_import(file, hash)
    import_options = hash[:options]
    if file.start_with?('node_modules') && file.match('/vendor/')
      file = file.sub /^node_modules.*?\/vendor\//, '' + 'vendor/'
      if import_options.present?
        # When a file is imported from an addon's vendor directory, it will be included in vendor.js.
        say_message "Options for 'vendor' file #{file.inspect} are ignored and will be included in vendor.js.", :yellow
        import_options = nil
      end
    end
    if import_options.present?
      stop_run "Build file import options must be a hash #{hash.inspect}."  unless import_options.kind_of?(Hash)
      "app.import('#{file}', #{import_options.to_json});"
    else
      "app.import('#{file}');"
    end
  end

  # ###
  # ### Trees.
  # ###

  def build_file_app_trees
    changes = Array.new
    import_trees.each do |hash|
      changes += format_build_file_tree_import(hash)
    end
    changes
  end

  def format_build_file_tree_import(hash)
    changes        = Array.new
    import_options = hash[:options]
    tree           = hash[:tree]
    stop_run "Build file import 'tree' options must be a hash #{hash.inspect}."  unless import_options.kind_of?(Hash)
    unless File.directory?(tree)
      say_message "Build file import 'tree' path does not exist #{tree.inspect}.  Skipping.", :yellow unless dry_run?
      return changes
    end
    stop_run "Build file import 'tree' does not contain option 'srcDir' #{hash.inspect}."  unless import_options[:srcDir].present?
    patterns = import_options[:include]
    stop_run "Build file import 'tree' does not contain option 'include' #{hash.inspect}."  unless patterns.present?
    source_dir   = import_options[:srcDir]
    path         = source_dir.present? ? File.join(tree, source_dir) : tree
    make_comment = false
    inside path do
      files = Dir.glob patterns
      if files.blank?
        say_message "Build file import 'tree' patterns #{path.inspect} #{patterns.inspect} did not match any files.  Changed to a comment.", :yellow
        make_comment = true
      else
        imported_files.push files
      end
    end
    add_comments_to_changes(changes, hash)
    line = "trees.push(pick_files('#{tree}', #{import_options.to_json}));"
    line = '// (no file match): ' + line if make_comment
    changes.push line
    changes
  end

  def add_comments_to_changes(changes, hash)
    return if (comment = hash[:comment]).blank?
    comments = Array.new
    [comment].flatten.each do |c|
      if c.blank?
        comments.push('')
      else
        comments.push c.start_with?('//') ? c : "// #{c}"
      end
    end
    changes.push(*comments)
  end

end; end; end; end
