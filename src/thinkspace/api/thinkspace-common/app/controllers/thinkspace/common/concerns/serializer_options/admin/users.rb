module Thinkspace
  module Common
    module Concerns
      module SerializerOptions
        module Admin
          module Users

            def select(serializer_options)
              serializer_options.remove_association :thinkspace_common_spaces
            end

            def refresh; end

            def switch(serializer_options)
              serializer_options.remove_all
            end

          end
        end
      end
    end
  end
end
