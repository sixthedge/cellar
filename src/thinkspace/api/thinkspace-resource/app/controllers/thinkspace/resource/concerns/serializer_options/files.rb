module Thinkspace
  module Resource
    module Concerns
      module SerializerOptions
        module Files

          def create(serializer_options)
            serializer_options.remove_association :resourceable
          end

          def show(serializer_options)
            serializer_options.remove_association  :taggable          
            serializer_options.remove_association  :resourceable
            serializer_options.remove_association  :thinkspace_common_user
            serializer_options.include_association :thinkspace_resource_tags
            serializer_options.blank_association   :thinkspace_common_user
          end

          def select(serializer_options); show(serializer_options); end

          def update(serializer_options)
            serializer_options.remove_association :taggable          
            # serializer_options.include_association :thinkspace_resource_tags
          end

          def destroy(serializer_options)
          end

        end
      end
    end
  end
end