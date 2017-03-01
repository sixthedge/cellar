# Allow model titles (e.g. assignments and phases) to be identical
# in different configs.
# Collects the model ids created by a config which can be used to
# add the ids to the 'find_by' options e.g. id: [1,2,3].
# Currently implemented for spaces, assignments and phases.
# To prevent adding the ids to the find_by call 'clear_find_by'.

require 'pp'
class CasespaceConfigModels

  attr_reader :config_model_ids
  attr_reader :find_config_name

  def initialize(caller, seed)
    @caller           = caller
    @seed             = seed
    @config_model_ids = new_hash
    @sep_len          = 100
    clear_find_by
  end

  def add(config, model)
    config_model_ids_array(config_name(config), model).push(model.id)
    set_find_by(config)
  end

  def find_by_ids(klass)
    return nil if find_config_name.blank?
    config_model_ids_array(find_config_name, klass)
  end

  def clear_find_by; @find_config_name = nil; end

  def set_find_by(config); @find_config_name = config_name(config); end

  def include_auto_input_model?(model, options); include_model?(model, options); end

  def print; pp config_model_ids; end

  def print_config_models; _print_config_models(find_config_name); end

  def print_models; _print_models; end

  private

  def config_model_ids_array(name, model_or_class)
    hash             = (config_model_ids[name] ||= new_hash)
    model_class_name = model_or_class.is_a?(Class) ? model_or_class.name : model_or_class.class.name
    (hash[model_class_name] ||= Array.new)
  end

  def include_model?(model, options)
    return false unless config_model_ids_array(find_config_name, model).include?(model.id)
    only   = [options[:only]].flatten.compact
    except = [options[:except]].flatten.compact
    title  = model.title
    case
    when title.blank?
      false
    when only.present?
      only.include?(title)
    when except.present?
      !except.include?(title)
    else
      true
    end
  end

  def new_hash; HashWithIndifferentAccess.new; end

  def config_name(config)
    config[:_config_name]
  end

  def _print_models
    config_model_ids.keys.sort.each do |name|
      _print_config_models(name)
    end
  end

  def print_config_models_header(name)
    hdr = color_line("Models for config (#{name})".ljust(@sep_len, '-'), :yellow, :bold)
    puts "\n", color_line(hdr, :on_blue)
  end

  def _print_config_models(name)
    return if name.blank?
    hash = config_model_ids[name] || {}
    return if hash.blank?
    indent = ' ' * 6
    print_config_models_header(name)
    keys = hash.keys.sort
    keys.each do |key|
      ids = hash[key]
      next if ids.blank?
      klass = key.safe_constantize
      next if klass.blank?
      puts "\n\n", color_line("  #{key} ids: #{ids}".ljust(@sep_len, '-'), :yellow)
      ids.each do |id|
        record = klass.find_by(id: id)
        if record.blank?
          puts color_line("#{key.inspect} record id [#{id}] not found.", :red, :bold)
        else
          lines = ''
          PP.pp(record, lines)
          lines.each_line do |line|
            line = color_line(line.chomp, :green, :bold) if line.match(/\s+id:\s\d+/)
            puts indent + line
          end
        end
        puts ''
      end
    end
    puts "\n\n"
  end

  def color_line(*args); @caller.color_line(*args); end

end
