module Test::Ability::Dictionary
  extend ActiveSupport::Concern
  included do

    def print_route_dictionary(dictionary, options={})
      print_route_dictionary_header(options)
      model_names   = dictionary.keys.map {|c| c.name}.sort
      nil_id_models = Array.new
      model_names.each do |model_name|
        model = dictionary.values.find {|m| m.class.name == model_name}
        if model.id.blank?
          nil_id_models.push(model)
          next
        end
        print_route_dictionary_model_header(model)
        pp model
      end
      if nil_id_models.present?
        puts "\n"
        puts "Models NOT saved (id == nil)"
        nil_id_models.each do |model|
          print_route_dictionary_model_header(model)
          pp model
        end
      end
      print_route_dictionary_sep
    end

    def print_route_dictionary_ids(dictionary, options={})
      print_route_dictionary_header(options)
      model_names = dictionary.keys.map {|c| c.name}.sort
      model_names.each do |model_name|
        model = dictionary.values.find {|m| m.class.name == model_name}
        print_route_dictionary_model_header(model)
        attributes = model.attributes
        max_len    = (attributes.keys.map {|k| k.length}.max || 0) + 2
        keys       = attributes.keys.sort
        keys.each do |key|
          next unless key.end_with?('_id')
          value      = attributes[key] || 'nil'
          basename   = key.sub(/_id$/,'')
          type_value = attributes["#{basename}_type"]
          attr_text  = "    #{key.ljust(max_len,'.')}#{value.to_s.rjust(5,'.')}"
          attr_text += "  [#{type_value}]"  if type_value.present?
          puts attr_text
        end
      end
      print_route_dictionary_sep
    end

    def print_route_dictionary_sep; puts '-' * 100; end

    def print_route_dictionary_header(options)
      title = options[:title] || name  # default to test name
      print_route_dictionary_sep
      puts "DICTIONARY: #{title}\n"      
    end

    def print_route_dictionary_model_header(model)
      puts "\n"
      puts '--' + "#{model.class.name}.#{model.id}".ljust(80, '-')
    end

  end # included
end
