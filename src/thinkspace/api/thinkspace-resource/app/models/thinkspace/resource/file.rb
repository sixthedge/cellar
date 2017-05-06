module Thinkspace
  module Resource
    class File < ActiveRecord::Base

      has_attached_file :file
      validates_attachment_content_type :file,
        content_type: %w(image/jpeg image/jpg image/png image/gif text/html text/plain application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document application/mspowerpoint application/vnd.ms-powerpoint application/vnd.openxmlformats-officedocument.presentationml.presentation application/pdf)

      def title;        file_file_name; end
      def content_type; file_content_type; end
      def size;         file_file_size; end
      def url;          file.url; end

      # After above Paperclip attributes otherwise displays a WARNING because the above attributes haven't been added yet.
      totem_associations

      def get_updateable; self.class.find(self.id); end  # return a record that can be updated (e.g. not through readonly association)

      def paperclip_path
        record = resourceable
        case record
        when Thinkspace::Casespace::Phase
          assignment = record.thinkspace_casespace_assignment
          space      = assignment.thinkspace_common_space
          "spaces/#{space.id}/assignments/#{assignment.id}/phases/#{record.id}/:filename"
        when Thinkspace::Casespace::Assignment
          space = record.thinkspace_common_space
          "spaces/#{space.id}/assignments/#{record.id}/:filename"
        when Thinkspace::Common::Space
          "spaces/#{record.id}/:filename"
        else
          "spaces/system/resource/:filename"
        end
      end

    end
  end
end
