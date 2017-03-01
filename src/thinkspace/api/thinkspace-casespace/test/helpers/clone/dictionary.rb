module Test::Clone::Dictionary
  extend ActiveSupport::Concern
  included do

    def print_dictionary(dictionary, options={})
      if options.kind_of?(String) || options.kind_of?(Symbol)  # backward compatible without options
        title = options
        id    = nil
      else
        title = options[:title] || name  # default to test name
        id    = options[:id]
      end
      puts '-' * 100
      puts "DICTIONARY: #{title}\n"      
      print_clone_dictionary_header
      dictionary.each do |key, value|
        puts "\n"
        puts "** #{key.inspect}"
        value.each do |from, to|
          puts "\n"
          if id.present?
            from_id = print_dictionary_record_id(from, id)
            to_id   = print_dictionary_record_id(to, id)
            if from_id.present? && to_id.present?
              len     = [from_id.to_s.length, to_id.to_s.length].max
              from_id = from_id.to_s.rjust(len)
              to_id   = to_id.to_s.rjust(len)
            end
          else
            from_id = ''
            to_id   = ''
          end
          puts "    [from=>#{from_id}] #{from.inspect}"
          puts "    [to===>#{to_id}] #{to.inspect}"
        end      
      end
    end

    def print_dictionary_record_id(record, id)
      case
      when record.respond_to?(id)
        id = record[id]
      when record.respond_to?(:authable_id)
        id = record[:authable_id]
      when record.respond_to?(:configurable)
        id = record[:configurable_id]
      when record.respond_to?(:componentable)
        id = record[:componentable_id]
      when record.respond_to?(:teamable_id)
        id = record[:teamable_id]
      when record.respond_to?(:resourceable_id)
        id = record[:resourceable_id]
      when record.respond_to?(:taggable_id)
        id = record[:taggable_id]
      else
        id = record[:id]
      end
      id.blank? ? '<nil>' : id
    end

    def print_options_dictionary_ids(options); print_dictionary_ids get_dictionary(options), options; end

    def print_dictionary_ids(dictionary, options={})
      puts "\n"
      puts '-' * 100
      title = options[:title] || name  # default to test name
      puts color_line("DICTIONARY: #{title}\n", :cyan, :bold)
      print_clone_dictionary_header
      dictionary.each do |key, value|
        puts "\n"
        puts color_line("** #{key.to_s.inspect}", :cyan)
        unless value.is_a?(Hash)
          puts "      No substitutions."
          next
        end
        value.each do |from, to|
          puts "\n"
          id_line = dictionary_from_to_ids(from, to, :id) + "  [#{key.to_s.classify.demodulize}]"
          id_line += "  [to-title: #{to.title.inspect}]"  if to.respond_to?(:title)
          puts id_line
          id_columns = get_dictionary_record_ids(from)
          id_columns.each do |col|
            puts dictionary_from_to_ids(from, to, col)
          end
        end      
      end
    end

    def dictionary_from_to_ids(from, to, column)
      from_id      = from.send(column)
      to_id        = to.send(column)
      from_text    = "from#{from_id.to_s.rjust(5,'.')}"
      to_text      = "to#{to_id.to_s.rjust(5,'.')}"
      same_id      = from_id == to_id
      message      = same_id ? '    == ' :  '       '
      color        = same_id ? :yellow : :white
      bold         = nil
      message     += "#{column.to_s.ljust(20,'.')} #{from_text}  #{to_text}"
      message     += '  nil'  if to_id.blank?
      poly_type    = get_record_polymorphic_type(from, column)
      message     += "  #{poly_type}"  if poly_type.present?
      if poly_type == user_class.name
        poly_assoc = column.sub(/_id$/,'')
        from_user  = from.send poly_assoc
        to_user    = to.send poly_assoc
        message   += from_id == to_id ? "[#{from_user.first_name}]" : " [#{from_user.first_name} -> #{to_user.first_name}]"
      end
      if column == 'user_id'
        from_user = user_class.find_by(id: from_id)
        to_user   = user_class.find_by(id: to_id)
        message  += from_id == to_id ? "  [#{from_user.first_name}]" : "  [#{from_user.first_name} -> #{to_user.first_name}]"
      end
      if same_id && column == :id  # if the id column ids are the same, probably an issue
        color = :red
        bold  = :bold
      end
      color_line(message, color, bold)
    end

    def get_record_polymorphic_type(record, column)
      regex = Regexp.new /_id$/
      return nil unless column.to_s.match(regex)
      type_column = column.to_s.sub(regex, '_type')
      return nil unless record.respond_to?(type_column)
      record.send type_column
    end

    def get_dictionary_record_ids(record)
      record.class.column_names.select{|c| c.end_with?('_id')}.sort
    end

    def print_clone_dictionary_header(color=:cyan)
      header = get_let_value(:clone_dictionary_header)
      return if header.blank?
      puts color_line(header, color)
    end

  end # included
end
