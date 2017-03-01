module Thinkspace
  module Resource
    module Api
      class LinksController < Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_serializer_options

        def create
          resourceable = current_ability.get_record_by_model_type_and_model_id(params_root[:resourceable_type], params_root[:resourceable_id])
          authorize!(:update, resourceable)

          @link.title        = params_root[:title]
          @link.url          = params_root[:url]
          @link.resourceable = resourceable
          @link.user_id      = current_user.id

          @link.thinkspace_resource_tag_ids = params_root[:new_tags]
          controller_save_record(@link)
        end

        def show
          controller_render(@link)
        end

        def select
          @links = @links.find(params[:ids])
          controller_render(@links)
        end

        def update
          authorize!(:update, @link)
          @link.title   = params_root[:title]
          @link.url     = params_root[:url]
          @link.user_id = current_user.id
          @link.thinkspace_resource_tag_ids = params_root[:new_tags]
          controller_save_record(@link)
        end

        def destroy
          authorize!(:destroy, @link)
          controller_destroy_record(@link)
        end

        private

        def error(errors)
          options          = {}
          options[:status] = 422
          options[:json]   = {:errors => errors}
          render options
        end

        def default_error_text
          'Invalid request for adding a URL.'
        end

      end
    end
  end
end