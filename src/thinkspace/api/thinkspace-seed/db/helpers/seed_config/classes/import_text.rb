module SeedConfigHelperClass; class ImportText

  # Provides the capability to update the config yaml file before converting into a hash.
  # All config changes are done at a text level (e.g. not at a hash level).
  # Therefore, the included file can reference YAML 'aliases' used in the config file.
  # The included text is indented at the same level as the 'import_text[]' statement.
  # By default, the source text files are assaumed to be in the 'imports' directory, but
  # can import from a 'config' by prefixing the filename with 'config_'.
  #
  # If the import file is solely used with 'import_text', it can have duplicate YAML 'alias' names
  # to allow importing one configurations.
  #
  # CAUTION: The imported text should be the same data type (e.g. array) if mixed into
  #          an existing data type.
  #
  # The import_text statement: import_text[filename@key]
  # NOTE: The 'key' is not included in the imported text.
  #
  # Example:
  #   imports/users.yml:
  #     read_1:
  #       - {role: *ROLE, first_name: read_1, ...}
  #     read_2:
  #       - {role: *ROLE, first_name: read_2, ...}
  #
  #   config:
  #     - &ROLE read
  #     users:
  #       import_text[users@read_1]
  #       import_text[users@read_2]

  attr_reader :namespace, :config_content, :regex
  attr_reader :import_files, :config_files

  def initialize(caller, seed, ns=nil)
    @caller         = caller
    @seed           = seed
    @namespace      = ns || :seed
    @config_content = Hash.new
    @import_files   = Hash.new
    @config_files   = Hash.new
    @regex          = Regexp.new /(\s*)import_text\[(.*?)\].*?\n/
  end

  def process(config_names)
    Array.wrap(config_names).each do |config_name|
      content     = @seed.test_config_content(config: config_name, namespace: namespace)
      new_content = get_import_content(content)
      if new_content.present?
        @seed.message color_line("--Processing import text (#{config_name}).", :green)
        config_content[config_name] = new_content if new_content.present?
      end
    end
    config_content
  end

  def get_import_content(content)
    return nil unless content.match(regex)
    new_content = ''
    content.each_line do |line|
      match = line.match(regex)
      next if line.strip.start_with?('#') # ignore if commented out
      if match.present?
        indent = match[1] or ''
        import = match[2]
        next if import.blank?
        new_content += import_file_key_content(import, indent)
      else
        new_content += line
      end
    end
    new_content
  end

  def import_file_key_content(import, indent)
    filename, key = import.split('@', 2)
    if filename.start_with?('config_')
      content = get_config_file_content(filename)
    else
      filename = filename.match(/\//) ? filename : "imports/#{filename}"  # if has slash assume contains folder
      content  = get_import_file_content(filename)
    end
    key = key.present? ? key : :import
    content_for_key(filename, content, key, indent)
  end

  def get_import_file_content(filename)
    content = import_files[filename]
    return content if content.present?
    content = @seed.test_import_content(namespace: namespace, import: filename)
    import_files[filename] = content
  end

  def get_config_file_content(filename)
    content = config_files[filename]
    return content if content.present?
    file                   = filename.sub('config_', '')
    content                = @seed.test_config_content(namespace: namespace, config: file)
    config_files[filename] = content
  end

  def content_for_key(filename, content, key, indent)
    key_content = ''
    found       = false
    start_with  = "#{key.to_s.strip}:"
    content.each_line do |line|
      next if line.chomp.strip.blank?
      if line.start_with?(start_with)
        found = true
        next
      end
      if found
        break if line.match /^\S/
        nline = line.lstrip
        n     = (line.length - nline.length) / 2 # indents on left
        i     = indent.length / 2 # indents for indent
        case
        when i == 0
        when i >  0   then n += i
        end
        n           -= 1
        n            = 0 if n < 0
        key_content += ('  ' * n) + nline
      end
    end
    @seed.error "Import file #{filename.inspect} does not have a key of #{key.inspect}." unless found
    key_content
  end

  def color_line(*args); @caller.color_line(*args); end

end; end
