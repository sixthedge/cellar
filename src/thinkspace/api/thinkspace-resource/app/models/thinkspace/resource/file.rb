module Thinkspace
  module Resource
    class File < ActiveRecord::Base

      has_attached_file :file
      validates_attachment_content_type :file,
        content_type: %w(image/jpeg image/jpg image/png image/gif text/html text/plain application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document application/mspowerpoint application/vnd.ms-powerpoint application/vnd.openxmlformats-officedocument.presentationml.presentation application/pdf)
        

      def title; file_file_name; end

      def content_type; file_content_type; end

      def size; file_file_size; end

      def url; file.url; end

      # After above Paperclip attributes otherwise displays a WARNING because the above attributes haven't been added yet.
      totem_associations

      def get_updateable; self.class.find(self.id); end  # return a record that can be updated (e.g. not through readonly association)

    end
  end
end
