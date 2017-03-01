module Totem; module Cli; module HelpersCopy; module Conversions

  # :file_path_conversions will do a gsub on the portion of the destination file path within (e.g. below) the destination directory.
  # It will match both the directory path AND the file name (defaults to the conversions in :file_content_conversions).
  #
  # File names that include the 'from' string are also converted to the 'to' string, for example a :file_path_conversion of:
  #   totem-core: totem-new-core #=> totem-core.gemspec => totem-new-core-gemspec
  # Note: files listed in :convert_files only have their 'content' converted (not their file path or name).
  #
  # The directory levels can be changed, but 'module' statements in the file content are not added/removed (need
  # to do manually).  For example, a :file_path_conversion of:
  #   mydir_1/mydir_2/mydir_3: mydir_1/mydir_3 #=> would remove the mydir_2 directory but files will still contain 'module MyDir2' statements.

  def get_from; run_options[:from]; end
  def get_to;   run_options[:to];   end

  def get_content_conversions; @_content_conversions   ||= [run_options[:file_content_conversions]].flatten.compact; end
  def get_path_conversions;    @_file_path_conversions ||= [run_options[:file_path_conversions]].flatten.compact;    end

  def set_copy_conversion_options
    case
    when get_from.present? && get_to.present?
      content_conversions = default_content_conversions
      path_conversions    = default_path_conversions
    when get_content_conversions.present? && get_path_conversions.present?
      content_conversions = get_content_conversions
      path_conversions    = get_path_conversions
    when get_content_conversions.present?
      content_conversions = get_content_conversions
      path_conversions    = get_content_conversions
    when get_path_conversions.present?
      content_conversions = get_path_conversions
      path_conversions    = get_path_conversions
    else
      content_conversions = nil
      path_conversions    = nil
    end
    run_options[:file_content_conversions] = content_conversions
    run_options[:file_path_conversions]    = path_conversions
  end

  def default_content_conversions
    from  = get_from.to_s
    to    = get_to.to_s
    array = Array.new
    array.push("#{from.downcase}-" => "#{to.downcase.dasherize}-")
    array.push(from                => to)
    array.push(from.downcase       => to.downcase)
    array.push(from.underscore     => to.underscore)
    array.push(from.camelize       => to.camelize)
    array.push(from.classify       => to.classify)
    array.push(from.upcase         => to.upcase)
    array
  end

  def default_path_conversions
    default_content_conversions
  end

  def add_acronyms
    acronyms = [options[:acronyms]].flatten.compact
    return if acronyms.blank?
    ActiveSupport::Inflector.inflections do |inflect|
      acronyms.each do |acronym|
        inflect.acronym acronym
      end
    end
  end

end; end; end; end
