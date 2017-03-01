module Totem
  module Core
    module Controllers
      module TotemParams

        # JSON-API data root.
        def params_data
          @_permitted_data ||= begin
            raise "Missing params[:data] controller params for [#{self.class.name}]"  unless params.has_key?(:data)
            permitted = params[:data]
            raise "Permitted params[:data] controller params for [#{self.class.name}] is invalid"  unless permitted.is_a?(::ActionController::Parameters)
            permitted.permit!.to_h
          end
        end

        # Controller's root key
        def params_root
          data = params_data
          raise "Missing params[:data][:attributes] controller params for [#{self.class.name}]"  unless data.has_key?(:attributes)
          data[:attributes]
        end

        # For associations within the controller's namespace
        def params_association_id(id_name)
          params_association_path_id("#{controller_association_params_key}/#{id_name}")
        end

        def params_association_path_id(assoc_key)
          assoc_key     = assoc_key.to_s.sub(/_id$/,'')
          data          = params_data
          relationships = data[:relationships]
          raise "Missing params[:data][:relationships] controller params for [#{self.class.name}]"  if relationships.blank?
          raise "Missing params[:data][:relationships][#{assoc_key}] controller params for [#{self.class.name}]"  unless relationships.has_key?(assoc_key)
          assoc_data = relationships[assoc_key]
          assoc_data[:data][:id]
        end

        def controller_association_params_key
          @_controller_association_params_key ||= self.class.totem_controller_model_class.deconstantize.underscore
        end

      end
    end
  end
end
