module Thinkspace
  module Common
    module Concerns
      module SerializerOptions
        module Users

          def show(serializer_options)
            serializer_options.remove_association :thinkspace_common_spaces
          end
          def update(serializer_options)
            serializer_options.remove_association :thinkspace_common_spaces
          end
          def sign_in(serializer_options); show(serializer_options); end
          def sign_out;   end;
          def stay_alive; end;
          def validate;   end;
          def create; end;
          def avatar; end;
          def update_tos; end;

        end
      end
    end
  end
end
