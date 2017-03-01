module Totem; module Cli; module HelpersCopy; module CopyContent

  # Called by overriding the Thor method 'copy_file'.
  # Note: If :file_path_conversions is blank in the config file, is set to :file_content_conversions.
  def totem_destination_path(destination_path)
    dir = destination_path.to_s.sub(/^#{destination_dir}/,'')
    get_path_conversions.each do |conversion|  # convert file paths e.g. totem/core => totem/mycore
      conversion.each do |from, to|
        dir.sub!(from.to_s, to.to_s)
      end
    end
    dir = dasherize_directory_basename(dir) if gemspec?(dir)
    dir = dasherize_directory_basename(dir) if lib?(dir)
    dir = File.join(destination_dir, dir)
    print_filename(dir)
    @file_destination_path = dir
  end

  # Called by totem_copy in Thor 'directory' block.
  def copy_content(content)
    if vendor? || binary? || git?
      collect_no_gsub_directories  if print_no_gsub?
    else
      gsub_content(content)
    end
    @file_destination_path = nil
    content
  end

  def gsub_content(content)
    get_content_conversions.each do |conversion|
      conversion.each do |from, to|
        from = Regexp.new(from.to_s)
        content.gsub! from do
          collect_content_changes(from, to)  if print_summary?
          to
        end
      end
    end
  end

  def collect_content_changes(from, to)
    from_key = from.instance_of?(Regexp) ? from.inspect : from.to_s
    # overall summary of change counts
    @gsub_content_change_counts ||= Hash.new
    @gsub_content_change_counts[from_key] ||= Hash.new(0)
    @gsub_content_change_counts[from_key][to] += 1
    # per file change counts
    file = @file_destination_path || 'unknown'
    @gsub_file_content_change_counts ||= Hash.new
    @gsub_file_content_change_counts[file] ||= Hash.new
    @gsub_file_content_change_counts[file][from_key] ||= Hash.new(0)
    @gsub_file_content_change_counts[file][from_key][to] += 1
  end

  def collect_no_gsub_directories
    @no_gsub_directories ||= Array.new
    path      = @file_destination_path.to_s.sub(/^#{destination_dir}/,'')
    dir       = File.dirname(path)
    collected = @no_gsub_directories.find {|d| @file_destination_path.start_with?(d)}
    @no_gsub_directories.push(dir)  if collected.blank?
  end

  def dasherize_directory_basename(dir)
    dirname  = File.dirname(dir)
    basename = File.basename(dir).dasherize
    File.join(dirname, basename)
  end

  # ### File type directory checks ### #

  BINARY_FILE_EXTENSIONS = ['.png', '.jpg', '.jpeg', '.svg', '.eot', '.tff', '.woff']

  def api?; options[:api]; end

  def vendor?; @file_destination_path.match(/\/vendor\//); end

  def binary?; BINARY_FILE_EXTENSIONS.include?(File.extname(@file_destination_path)); end

  def git?; @file_destination_path.match(/\/\.git\//); end

  def gemspec?(dir); api? && File.extname(dir) == '.gemspec'; end

  def lib?(dir)
    return false unless (api? && dir.match(/\/lib\//))
    basename = File.basename(dir)
    return false unless File.extname(basename) == '.rb'
    dir.match("\/lib\/#{basename}$")
  end

end; end; end; end
