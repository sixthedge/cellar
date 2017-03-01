module Thinkspace
  module Resource
    module Api
      class FilesController < Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_serializer_options

        def create
          resourceable = current_ability.get_record_by_model_type_and_model_id_from_params(params)
          authorize!(:update, resourceable)

          files = params[:files]
          # Should probably return error JSON for all returns.
          # return error(default_error_text) if not resourceable_type or not resourceable_id or not files
          return error(default_error_text) unless files.present?

          created_files = []
          files.each do |file|
            ts_file = Thinkspace::Resource::File.new(file: file, thinkspace_common_user: current_user, resourceable: resourceable)
            if ts_file.save
              created_files << ts_file
            else
              return error(ts_file.errors)
            end
          end
          controller_render(created_files)
        end

        def show
          controller_render(@file)
        end

        def select
          @files = @files.find(params[:ids])
          controller_render(@files)
        end

        def update
          authorize!(:update, @file)
          # Authorize tag ids belong to resourceable
          if params_root[:new_tags].present?
            @file.thinkspace_resource_tag_ids = params_root[:new_tags]
          end
          controller_render(@file)
        end

        def destroy
          authorize!(:destroy, @file)
          controller_destroy_record(@file)
        end

        private

        def error(errors)
          options          = {}
          options[:status] = 422
          options[:json]   = {:errors => errors}
          render options
        end

        def default_error_text
          'Invalid request for uploading a file.'
        end

      end
    end
  end
end