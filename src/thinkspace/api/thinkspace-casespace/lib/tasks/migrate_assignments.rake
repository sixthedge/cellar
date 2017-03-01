require 'csv'

namespace :thinkspace do

  migrate_namespace = namespace :migrate do

      task :assignments, [] => [:environment] do |t, args|
        migrate_namespace['assignment_require_file'].invoke :parse_xml
        migrate_namespace['assignment_parse_xml_class'].invoke
        @assignment_parse_xml_class.new.process args.extras
      end

      task :inspect, [] => [:environment] do |t, args|
        script = ENV['S'] || ENV['SCRIPT']
        if script.blank?
          puts "Must supply an environment script name e.g. rake ... SCRIPT=name"
          exit
        end
        migrate_namespace['assignment_require_file'].invoke "inspect/#{script}"
        class_name = "Thinkspace::Migrate::Assignments::Inspect::#{script.camelize}"
        klass      = class_name.safe_constantize
        if klass.blank?
          puts "Class #{class_name.inspect} cannot be constantized."
          exit
        end
        klass.new.process args.extras
      end

      task :assignment_parse_xml_class do |t, args|
        @assignment_parse_xml_class ||= Thinkspace::Migrate::Assignments::ParseXml
      end

      task :assignment_require_file, [:filename] do |t, args|
        spec      = Gem::Specification.find_by_path('thinkspace')
        gem_dir   = spec.gem_dir
        path      = File.join(gem_dir, 'migrate', 'assignments')
        file_path = File.join(path, args.filename.to_s)
        filename  = file_path + '.rb'  unless file_path.end_with?('.rb')
        unless File.file?(filename)
          puts "File #{filename.inspect} does not exist."
          exit
        end
        require file_path
      end

      task :convert_dp_to_ts1, [] => [:environment] do |t, args|
        relative = ENV['PATH']
        raise "No relative path was set for dp_to_ts1." unless relative.present?
        path     = File.expand_path(relative, __FILE__)
        process(path)
      end

      def process(path)
        directories    = Dir.glob(path + '/assignments/*').select { |f| File.directory?(f) }
        csv_directory  = path + '/csv'
        file_ids_map   = File.open(csv_directory + '/ids_map.csv') if File.exist?(csv_directory + '/ids_map.csv')
        file_files_map = File.open(csv_directory + '/files_map.csv') if File.exist?(csv_directory + '/files_map.csv')
        @csv_ids_map   = CSV.parse(file_ids_map, headers: true) if file_ids_map.present?
        @csv_files_map = CSV.parse(file_files_map, headers: true) if file_files_map.present?

        directories.each do |assn|
          @assn          = assn
          item_types_xml = assn + '/itemtypes.xml'
          diagnosis_xml  = assn + '/diagnosis.xml'
          lab_test_xml   = assn + '/phase2.xml'

          item_types_doc = process_item_types(File.open(item_types_xml))
          diagnosis_doc  = process_diagnosis(File.open(diagnosis_xml))
          lab_test_doc   = process_lab_test(File.open(lab_test_xml))

          if ENV['WRITE'] == 'true'
            File.write(diagnosis_xml, diagnosis_doc.to_xml)
            File.write(item_types_xml, item_types_doc.to_xml)
            File.write(lab_test_xml, lab_test_doc.to_xml)
          end
        end
      end

      def process_item_types(file)
        has_m      = false
        has_d      = false
        has_h      = false
        doc        = Nokogiri::XML(file)
        item_types = doc.css("itemtypes itemtype")
        id         = 0

        item_types.each_with_index do |item_type, index|
          item_type.delete('isFolder')
          item_type.delete('parent')
          icon               = item_type.delete('itemTypeIcon')
          name               = item_type.delete('itemTypeName')
          has_m              = true if name.to_s == 'M'
          has_d              = true if name.to_s == 'D'
          has_h              = true if name.to_s == 'H'
          item_type['icon']  = icon
          item_type['name']  = name
          item_type['label'] = get_label_from_name(name)
          id                 = index + 1
        end
        # Add basic types that are referenced in the phase as `itemType` if th ey are not present.
        unless item_types.empty?
          id = add_item_type(item_types, doc, 'M.jpg', 'M', 'New Mechanism', id) unless has_m
          id = add_item_type(doc, 'D.jpg', 'D', 'Data Abnormality', id) unless has_d
          id = add_item_type(doc, 'H.jpg', 'H', 'History', id) unless has_h
        end
        root       = doc.at_css('itemtypes')
        root['_n'] = id
        doc
      end

      def process_diagnosis(file)
        doc            = Nokogiri::XML(file)
        items          = doc.css("items item")
        parents        = Hash.new
        current_parent = 0
        indent         = 0
        items.each_with_index do |item, index|
          item.delete('isFolder')
          icon   = item.delete('icon')
          type   = icon.text.split('.').first
          parent = item.delete('parent').text.to_i
          if current_parent != parent
            case 
            when parent == 1000
              indent = 0
            when current_parent > parent
              indent -= 1
            when current_parent < parent
              indent += 1
            end
            current_parent = parent
          end
          item << new_node(doc, 'comment')
          item << new_node(doc, 'phrase')
          item << new_node(doc, 'type', type)
          item << new_node(doc, 'collapsed', false)
          item << new_node(doc, 'extra', false)
          item << new_node(doc, 'indent', indent)
        end
        doc
      end

      def process_lab_test(file)
        doc        = Nokogiri::XML(file, nil, 'ISO-8859-1')
        lab_tests  = doc.css('labtests labtest')
        categories = Array.new
        lab_tests.each do |lab_test|
          # Set the correct <panel> value.
          type = lab_test.at_css('type')
          unless type.blank?
            name   = lab_test.at_css('name')
            @panel = name.text.upcase if !name.blank? && type.text == 'title'
            if @panel.present?
              lab_test.at_css('panel').content = @panel 
              categories.push @panel unless categories.include?(@panel)
            end
          end

          # Convert <ratings> into the appropriate format.
          ratings = lab_test.at_css('ratings')
          unless ratings.blank?
            correct        = ratings.delete('correct')
            normal         = ratings.delete('normal')
            correct_rating = new_node(doc, 'correctRating', correct)
            normal_rating  = new_node(doc, 'normalRating', normal)
            ratings.add_next_sibling correct_rating
            ratings.add_next_sibling normal_rating
          end

          # Change URL in results if they are present from ImageData href.
          result = lab_test.at_css('result')
          unless result.blank?
            correct_result_image_data(result)
          end
        end

        # Ensure the <panel> value has a <type>header</type> entry.
        headers = doc.css('labtests labtest type:contains("header")')
        categories.each do |category|
          has_header = false
          headers.each do |header|
            parent     = header.parent
            has_header = true if parent.at_css('panel').text == category
          end
          unless has_header
            node = new_header_node(doc, category)
            lab_tests.after(node)
          end
        end

        doc
      end

      def correct_result_image_data(result)
        content = result.text
        if content.match(/ImageData:\d*/)
          fragment = Nokogiri::HTML::fragment(content)
          anchors  = fragment.css('a')
          anchors.each do |anchor|
            image_data       = anchor['href']
            image_data_id    = image_data.split(':').pop
            file_name        = get_file_from_image_data_id(image_data_id)
            anchor['href']   = file_name
            anchor['target'] = '_blank'
          end
          result.content = fragment.to_html
        end
      end

      def get_file_from_image_data_id(id)
        image_id          = nil
        file_name         = nil
        storage           = ENV['BUCKET_URL']
        if storage.present?
          url_prepend = storage.dup
          url_prepend << '/' unless url_prepend.ends_with?('/')
        end
        @csv_ids_map.each do |row|
          image_id = row['ImageId'] if row['ImageDataId'] == id
        end
        return nil unless image_id.present?
        @csv_files_map.each do |row|
          file_name = row['FileName'] if row['ImageId'] == image_id
        end
        return nil unless file_name.present?
        file_name = file_name.split('/').pop
        url_prepend.present? ? url_prepend + file_name : file_name
      end

      # ### Helpers
      def get_label_from_name(name)
        case name.to_s
        when 'M'
          'New Mechanism'
        when 'D'
          'Data Abnormality'
        when 'H'
          'History'
        else
          'No label provided'
        end
      end

      def new_node(doc, name, content=nil)
        node         = Nokogiri::XML::Node.new(name, doc)
        node.content = content unless content.nil?
        node
      end

      def new_header_node(doc, panel)
        node = Nokogiri::XML::Node.new('labtest', doc)
        node << new_node(doc, 'name', 'Test Name')
        node << new_node(doc, 'description')
        node << new_node(doc, 'type', 'header')
        node << new_node(doc, 'result', 'Test Result')
        node << new_node(doc, 'ratings', 'Species')
        node << new_node(doc, 'lowerBound', 'Ref Int')
        node << new_node(doc, 'upperBound')
        node << new_node(doc, 'units', 'Units')
        node << new_node(doc, 'abnormality', 'Abnormality Name')
        node << new_node(doc, 'panel', panel)
        node << new_node(doc, 'observationFormat', '{Abnormality}')
        node
      end

      def add_item_type(set, doc, icon, name, label, id)
        node          = Nokogiri::XML::Node.new('itemtype', doc)
        id           += 1
        node['icon']  = icon
        node['name']  = name
        node['label'] = label
        node['_id']   = id
        set.after node
        id
      end

  end
end
