module Thinkspace
  module Common
    module DeepCloneHelper

      public

      def get_clone_dictionary(options={}); options[:dictionary] || Hash.new; end

      def get_record_dictionary_key(record); record.class.name.underscore.pluralize.to_sym; end

      private

      def clone_self(options={}, include_associations=[], id_columns=nil)
        clone_record(self, options, include_associations, id_columns)
      end

      def clone_record(record, options, include_associations=[], id_columns=nil)
        dictionary = get_clone_dictionary(options)
        id_columns = [id_columns].flatten.compact
        cloned_record = record.deep_clone include: include_associations, dictionary: dictionary do |original, kopy|
          clone_block(original, kopy, options)
          clone_id_columns(id_columns, original, kopy, options)  if id_columns.present?
        end
        cloned_record
      end

      def clone_block(original, kopy, options)
        clone_block_replace_authable(kopy, options)
        clone_block_replace_ownerable(kopy, options)
        clone_block_replace_user_id(kopy, options)
      end

      def clone_block_replace_authable(kopy, options)
        dictionary = get_clone_dictionary(options)
        if kopy.class.reflect_on_association(:authable)
          authable        = options[:authable] || self
          cloned_authable = get_cloned_record_from_dictionary(authable, dictionary)
          raise_clone_exception("Cloned authable #{authable.class.name.inspect} not found in dictionary [id: #{authable.id}].") if cloned_authable.blank?
          kopy.authable = cloned_authable
        end
      end

      def clone_block_replace_ownerable(kopy, options)
        ownerable = options[:ownerable]
        return if ownerable.blank?
        if kopy.class.reflect_on_association(:ownerable)
          kopy.ownerable = ownerable
        end
      end

      def clone_block_replace_user_id(kopy, options)
        user    = options[:user]
        user_id = options[:user_id]
        return if user.blank? && user_id.blank?
        user_id = user.id  if user_id.blank?
        return if user_id.blank?
        if kopy.class.column_names.include?('user_id')
          kopy.user_id = user_id
        end
      end

      def clone_id_columns(id_columns, original, kopy, options)
        dictionary = get_clone_dictionary(options)
        id_columns.each do |id_column|
          next unless original.respond_to?(id_column)
          id = original.send(id_column)
          return if id.blank?
          original_record_for_id = original.class.find_by(id: id)
          raise_clone_exception("Clone #{original.class.name.inspect} not found [id: #{original.id}].") if original_record_for_id.blank?
          cloned_record_id = nil
          cloned_record    = get_cloned_record_from_dictionary(original_record_for_id, dictionary)
          cloned_record_id = cloned_record.id  if cloned_record.present?
          kopy.send("#{id_column}=", cloned_record_id)
        end
      end

      # ###
      # ### Helpers.
      # ###

      def clone_save_record(record, message='Save error:')
        unless record.save
          message += " #{record.class.name.inspect}:\n#{record.inspect}\nValidation errors: #{record.errors.full_messages.inspect}."
          raise_clone_exception(message)
        end
        record
      end

      def get_cloned_record_from_dictionary(record, dictionary)
        key  = get_record_dictionary_key(record)
        hash = dictionary[key]
        return nil if hash.blank?
        return nil unless hash.is_a?(Hash)
        hash[record]
      end

      def get_clone_title(title, options={})
        if is_full_clone?(options) || options[:keep_title].present?
          title
        elsif options[:title].present?
          options[:title]
        else
          'clone: ' + (title || '')
        end
      end

      def clone_include?(key, options, default=true)
        options.has_key?(key) ? options[key] == true : default
      end

      def is_full_clone?(options); options[:is_full_clone] == true; end

      def raise_clone_exception(message)
        raise CloneError, message
      end

      class CloneError < StandardError; end

    end
  end
end
