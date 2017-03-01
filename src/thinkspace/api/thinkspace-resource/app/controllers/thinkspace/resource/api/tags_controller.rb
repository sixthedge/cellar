module Thinkspace
  module Resource
    module Api
      class TagsController < Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_serializer_options

        def create
          taggable = current_ability.get_record_by_model_type_and_model_id(params_root[:taggable_type], params_root[:taggable_id])
          authorize!(:update, taggable)
          @tag.user_id  = current_user.id
          @tag.title    = params_root[:title]
          @tag.taggable = taggable
          controller_save_record(@tag)
        end

        def show
          controller_render(@tag)
        end

        def select
          @tags = @tags.find(params[:ids])
          controller_render(@tags)
        end

        def update
          taggable = current_ability.get_record_by_model_type_and_model_id(params_root[:taggable_type], params_root[:taggable_id])
          raise_access_denied_exception "Cannot update tag.", :update, @tag  unless taggable == @tag.taggable
          authorize!(:update, taggable)
          @tag.title = params_root[:title]
          controller_save_record(@tag)
        end

        def destroy
          authorize!(:update, @tag.taggable)
          controller_destroy_record(@tag)
        end

      end
    end
  end
end