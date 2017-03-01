module Totem; module Cli; module HelpersEmber; module Templates

  def install_platform_template(filename, options={})
    variables = options.is_a?(Hash) ? options : Hash.new
    variables = variables.reverse_merge(ember_template_variables)
    content = nil
    if options[:as_is_if_exists]
      content = ember_platform_template_content(filename)
      if content.present?
        content = erb_content(content, variables)
        install_create_file(filename, content) unless dry_run?
        return
      end
    end
    content = ember_platform_template(filename, variables)
    if content.blank?
      install_template(filename) if totem_ember_template?(filename) && !dry_run?
    else
      install_create_file(filename, content) unless dry_run?
    end
  end

  def install_create_file(filename, content)
    message = "Installing #{filename.inspect}"
    say_message message, run_message_color
    inside @app_path do
      create_file filename, content, verbose: verbose_copy? unless dry_run?
    end
  end

  def install_template(filename)
    message = "Installing template #{filename.inspect}"
    say_message message, run_message_color
    inside @app_path do
      source_file = File.join(template_dir, filename).to_s
      template source_file, filename, verbose: verbose_copy? unless dry_run?
    end
  end

  def ember_platform_template(filename, variables)
    tt_content = totem_ember_template_content(filename)
    content    = ember_platform_template_content(filename)
    case
    when tt_content.blank?   && content.present?  then erb_content(content, variables)
    when tt_content.present? && content.blank?    then erb_content(tt_content, variables)
    else
      content = erb_content(content, variables)
      erb_content(tt_content, variables.merge(template_content: content))
    end
  end

  def totem_ember_template?(filename)
    return false if template_dir.blank? || filename.blank?
    file = File.join(template_dir, filename + '.tt')
    File.file?(file)
  end

  def totem_ember_template_content(filename)
    file = File.join(template_dir, filename).to_s + '.tt'
    File.file?(file) ? File.read(file) : nil
  end

  def ember_platform_template_content(filename)
    file = find_src_file(filename, src_paths: template_paths)
    return nil if file.blank?
    File.file?(file) ? File.read(file) : nil
  end

  def ember_template_variables
    hash = current_package[:variables] || Hash.new
    hash[:module_prefix] = @app_name unless hash.has_key?(:module_prefix)
    hash
  end

  def erb_content(content, variables); new_erb.erb_text(content, variables); end

  def new_erb; Helpers::PlatformErb.new(self); end

end; end; end; end
