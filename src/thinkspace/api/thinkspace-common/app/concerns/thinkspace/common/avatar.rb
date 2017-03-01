module Thinkspace
  module Common
    module Avatar

      extend ::ActiveSupport::Concern

      included do
        has_attached_file :avatar, default_url: :get_default_avatar_url, styles: { full: "150x150#" }
        validates_attachment_content_type :avatar,
          content_type: %w(image/jpeg image/jpg image/png image/gif image/svg)
      end

      def avatar_title;        avatar_file_name;    end
      def avatar_size;         avatar_file_size;    end
      def avatar_url;          avatar.url(:full);   end

      def get_default_avatar_url
        return get_default_avatar_path unless Rails.env.production?
        host        = 'https://s3.amazonaws.com/'
        bucket_name = Rails.application.secrets.aws['s3']['paperclip']['bucket_name']
        path        = get_default_avatar_path
        return (host + bucket_name + path)
      end

    end
  end
end