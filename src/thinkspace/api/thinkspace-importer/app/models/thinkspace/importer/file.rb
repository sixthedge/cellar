require 'csv'

module Thinkspace
  module Importer
    class File < ActiveRecord::Base
      has_attached_file                 :attachment
      validates_attachment_content_type :attachment, content_type: %w(text/csv text/plain application/octet-stream application/vnd.ms-excel)
      before_save                       :set_settings_will_change

      def title
        attachment_file_name
      end

      def content_type
        attachment_content_type
      end

      def size
        attachment_file_size
      end

      def url
        custom_url || attachment.url
      end

      # ### CSV processing/helpers
      def process(contents = nil)
        contents = open(url) unless contents
        csv      = ::CSV.parse(contents, headers: get_single_header.blank?)
        records  = process_csv(csv)
        records
      end

      def process_csv(csv)
        sanity_checks
        headers = if get_single_header.present? then [get_single_header] else get_valid_headers_for_csv(csv) end # Should contain nested hash keys and direct column values.
        records = []
        get_generated_model_class.transaction do
          csv.each do |row|
            validate_row_contains_required_headers(row) 
            record = get_generated_model_instance
            headers.each do |header|
              set_record_value_from_header_and_row(record, header, row)
            end
            process_attributes_for_record(record)
            process_nested_attributes_for_record(record)
            records << save_csv_generated_record(record)
          end
        end
        records
      end

      def process_attributes_for_record(record)
        attributes = get_attributes
        return unless attributes.present?
        return unless attributes.kind_of?(Hash)
        attributes.each do |k, v|
          method = get_method_from_header(k.to_s)
          record.send(method, v) if record.respond_to?(method)
        end
      end

      def process_nested_attributes_for_record(record)
        # Only root level keys can be column values.  The rest are nested.
        nested_attributes = get_nested_attributes
        return unless nested_attributes
        nested_attributes.each do |k, v|
          next unless record.respond_to?(k)
          hash = record.send(k)
          next unless hash
          merged_hash = hash.deep_merge(nested_attributes[k])
          method      = get_method_from_header(k.to_s)
          record.send(method, merged_hash)
        end
      end

      def process_after_save_methods_for_record(record)
        after_save_methods = get_after_save_methods
        return unless after_save_methods.present?
        after_save_methods.each do |method|
          record.send(method) if record.respond_to?(method)
        end
      end

      def sanity_checks
        valid_headers = get_valid_headers
        error SoftInvalidHeadersError, "No [:headers][:valid] are defined for the file.  Processing halted.  File: #{self.inspect}" unless valid_headers.present? or get_single_header.present?
        validate_required_headers
      end

      def save_csv_generated_record(record)
        if get_save_bool
          process_after_save_methods_for_record(record) if record.save
        end
        record
      end

      def get_valid_headers_for_csv(csv)
        headers      = get_combined_valid_headers_from_csv(csv)
        model        = get_generated_model_instance
        headers.each do |header|
          # If the header has a ':' in it, just shift the first value as that is the column.
          # => Each subsequent string is a nested hash key.
          # => This is the convention used to create a nested settings:json type column.
          method = get_method_from_header(header)
          headers.delete(header) unless model.respond_to?(method)
        end
        headers
      end

      def get_combined_valid_headers_from_csv(csv)
        # Get the corresponding headers that the model would respond_to? from the valid headers setting and the csv file itself.
        csv_headers   = csv.headers
        valid_headers = get_valid_headers
        headers       = []
        csv_headers.each do |header|
          base_header = header
          header      = header.split(':').shift if is_nested_header?(header)
          headers     << base_header if valid_headers.include?(base_header)
        end
        headers
      end

      def validate_required_headers
        required_headers = get_required_headers
        return unless required_headers.present? # Return if no required headers are specified.
        model            = get_generated_model_instance
        model_class      = get_generated_model_class
        required_headers.each do |header|
          method = get_method_from_header(header)
          error HardInvalidRequiredHeadersError, "Invalid required headers; the #{model_class} model does not respond to '#{method}'. Processing halted. File: #{self.inspect}" unless model.respond_to?(method)
        end
      end

      def validate_row_contains_required_headers(row)
        headers = get_required_headers
        return unless headers.present? # Return if no required headers are specified.
        headers.each do |h|
          error SoftHeaderRequirementsNotMetError, "CSV row did not contain the required header '#{h}'. Processing Halted. Row: #{row.inspect}" unless row[h]
        end
      end

      # ### `generated_model` helpers
      def get_generated_model_class
        error InvalidModelError, "Invalid model defined for file: #{self.inspect}." unless generated_model.present?
        model_class = generated_model.safe_constantize
        error InvalidModelError, "Invalid model constantization for: #{model_class}." unless model_class
        model_class
      end

      def get_generated_model_instance
        model_class = get_generated_model_class
        model_class.new
      end

      # ### `header` helpers
      def get_method_from_header(header)
        if header.include?(':')
          method_name = header.split(':').shift
          method = "#{method_name}="
        else
          method = "#{header}="
        end
        method
      end

      def is_nested_header?(header)
        header.include?(':')
      end

      def set_record_value_from_header_and_row(record, header, row)
        # Headers should be pre-validated at this point, so a send on it should be fine.
        method = get_method_from_header(header)
        if is_nested_header?(header)
          keys          = header.split(':')
          column        = keys.shift
          original_hash = record.send("#{column}")
          error HardInvalidNestedKeyColumnError, "There was no resultant hash from getting column of: [#{column}]" unless original_hash.kind_of?(Hash)
          hash   = set_nested_key_value(original_hash, *keys, row[header])
          record.send(method, hash)
        else
          if get_single_header.present?
            record.send(method, row.first)
          else
            record.send(method, row[header])
          end
        end
      end

      def set_nested_key_value(hash, *keys, last_key, value)
        result = keys.inject(hash) do |r, k|
          r[k] ||= {}
          r[k]
        end

        result[last_key] = value
        hash
      end

      # ### `settings` helpers
      # The settings could look like:
      # {
      #   headers: { valid: ['first_name', 'last_name', 'email'] },
      #   after_save: ['send_invitation'],
      #   attributes: { email: 'testing@test.com'} 
      # }
      # ### headers[:valid] is required.
      # ### all others are optional.
      def get_settings
        self.settings.with_indifferent_access
      end

      def get_settings_value(*args)
        settings = get_settings
        args.each do |arg|
          settings.has_key?(arg) ? settings = settings[arg] : settings = nil
          return nil unless settings
        end
        settings
      end

      def get_valid_headers
        get_settings_value(:headers, :valid)
      end

      def get_required_headers
        get_settings_value(:headers, :required)
      end

      def get_single_header
        get_settings_value(:headers, :single)
      end

      def get_save_bool
        get_settings_value(:save).present? ? get_settings_value(:save) : true # save by default
      end

      def get_after_save_methods
        get_settings_value(:after_save)
      end

      def get_attributes
        get_settings_value(:attributes)
      end

      def get_nested_attributes
        get_settings_value(:nested_attributes)
      end

      # At bottom because it will throw a WARNING otherwise because they above methods haven't been added yet.
      totem_associations

      private

      def error(klass, message)
        raise klass, message
      end

      # This is REQUIRED until Rails 4.2
      # => ActiveRecord does not flag JSON/Hstore columns as dirty (subsequently avoiding the update) in all instances.
      # => This forces a rewrite of the settings column everytime.
      def set_settings_will_change
        self.settings_will_change!
      end
    end

    # ### Error definitions
    class HardImporterError < StandardError; end;
    class InvalidModelError < HardImporterError; end;
    class SoftImporterError < StandardError; end;
    class SoftInvalidHeadersError < SoftImporterError; end;
    class SoftHeaderRequirementsNotMetError < SoftImporterError; end;
    class HardInvalidRequiredHeadersError < HardImporterError; end;
    class HardInvalidNestedKeyColumnError < HardImporterError; end;
  end
end