module Thinkspace
  module Team
    module Api
      class TeamCategoriesController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class

        def index
          controller_render(@team_categories)
        end

        def show
          controller_render(@team_category)
        end

      end
    end
  end
end
