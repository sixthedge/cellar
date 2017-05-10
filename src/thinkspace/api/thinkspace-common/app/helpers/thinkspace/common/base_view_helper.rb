module Thinkspace
  module Common
    module BaseViewHelper

      def cdn_image_url(filename)
        static_assets_url = Rails.application.secrets.aws['s3']['static_assets_url']
        static_assets_url + 'images/' + filename
      end

    end
  end
end