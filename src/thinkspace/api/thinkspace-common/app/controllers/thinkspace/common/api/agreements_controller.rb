module Thinkspace
  module Common
    module Api
      class AgreementsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_serializer_options

        def show
          controller_render(@agreement)
        end

        def index
          controller_render(@agreements)
        end

        def select
          @agreements = @agreements.where(id: params[:ids])
          controller_render(@agreements)
        end

        def latest_for
          type = params[:data][:doc_type]

          ## Can add more here if needed when we know more about the various doc types
          agreement = Thinkspace::Common::Agreement.where("doc_type = ? and effective_at IS NOT NULL", type).order('effective_at').last
          
          if agreement.present?
            controller_render(agreement)
          else
            controller_render_no_content
          end
        end

      end
    end
  end
end