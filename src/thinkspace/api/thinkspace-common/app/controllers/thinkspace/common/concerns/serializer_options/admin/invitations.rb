module Thinkspace
  module Common
    module Concerns
      module SerializerOptions
        module Admin
          module Invitations

            def create(serializer_options)
              serializer_options.include_association :thinkspace_common_user
            end

            def destroy(serializer_options); end;
            def refresh(serializer_options); end;
            def resend(serializer_options); end;
            def import(serializer_options); end;
            def fetch_state(serializer_options); end;

          end
        end
      end
    end
  end
end