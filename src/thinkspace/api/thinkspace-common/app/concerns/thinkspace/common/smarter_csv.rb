module Thinkspace
  module Common
    module SmarterCSV
      extend ActiveSupport::Concern

      def convert_to_single_column(file, options={})

        @errors = []

        match     = options[:match]
        delimiter = options[:delimiter] ||= "\n"
        hard_error NoMatchProvidedError, "No match string or regex provided for file: #{file.inspect}." unless match.present?

        data = ::SmarterCSV.process(file, row_sep: :auto)
        hard_error InsufficientNumberOfRowsError, "Fewer than 2 rows provided for file: #{file.inspect}." if data.size < 1
        
        # keys represent headers, e.g. the first row, so add these to the array of values to match in case headers are not provided
        values    = []
        first_row = data.first

        values << first_row.keys.map { |k| k.to_s } # convert from symbol to string

        data.each do |row| values << row.values end

        matched_values = []

        values.each do |row|
          matched_columns = row.select { |col| col =~ match }
          hard_error UnmatchedRowError, "Row #{row.inspect} does not contain a value matching #{match}." if matched_columns.empty? and row != values.first 
          hard_error OvermatchedRowError, "Row #{row.inspect} contains multiple values matching #{match}." if matched_columns.size > 1
          matched_values << matched_columns.first.downcase if matched_columns.one?
        end

        file_data = matched_values.uniq.join(delimiter)

        return file_data, @errors
        
      end

      def importer_file_class; Thinkspace::Importer::File; end

      private

      def hard_error(klass, message)
        raise klass, message
      end

      def soft_error(klass, message)
        @errors << {error: klass, message: message}
      end

      class NoMatchProvidedError < StandardError; end
      class InsufficientNumberOfRowsError < StandardError; end
      class UnmatchedRowError < StandardError; end
      class OvermatchedRowError < StandardError; end

    end
  end
end
