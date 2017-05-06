module Test; module Ability; module Controllers; module Thinkspace; module Lab; module Api

  module Admin
    class CategoriesController
      def params_create_can_update_authorized(route)
        category = route.get_model_params
        category[:title] += Time.now.to_s
      end
    end
  end

end; end; end; end; end; end
