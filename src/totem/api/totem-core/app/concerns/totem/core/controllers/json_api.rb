module Totem
  module Core
    module Controllers
      module JsonApi

        # ######################################################################################
        # @!group Common controller methods to access JSON API helpers
     
        # JSON API helpers
        def extract_included_records(options={})
          included = params_root[:included]
          unless included.present?
            if options[:single] then return nil else return [] end
          end
          records  = []
          included.each do |data|
            data       = ActiveSupport::HashWithIndifferentAccess.new(data)
            type       = data[:type]
            attributes = data[:attributes]
            klass      = type.singularize.classify.safe_constantize
            next unless klass.present?
            record = klass.new
            attributes.each do |attribute, value|
              column = get_column_from_attribute(record, attribute)
              record.send "#{column}=", value if record.respond_to?(column) && !record.send(column).present?
            end
            records << record
          end
          options[:single] ? records.first : records
        end

        def get_column_from_attribute(record, attribute)
          # Return the 'user_id' as a column instead of the full namespaced path if it exists.
          if attribute.include?('/') && attribute.include?('_id')
            klass     = attribute.gsub('_id', '')
            if klass.classify.safe_constantize.present?
              column    = attribute.split('/').pop
              attribute = column if record.respond_to?(column)
            end
          end
          attribute
        end

      end
    end
  end
end