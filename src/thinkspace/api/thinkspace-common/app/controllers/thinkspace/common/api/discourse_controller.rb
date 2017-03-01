module Thinkspace
  module Common
    module Api
      class DiscourseController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        include ::Totem::Settings.module.totem.controller_discourse_api
        before_action :set_api_credentials
        before_action :set_api_client

      end
    end
  end
end
