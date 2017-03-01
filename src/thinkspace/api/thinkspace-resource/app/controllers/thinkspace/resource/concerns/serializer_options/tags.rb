module Thinkspace
  module Resource
    module Concerns
      module SerializerOptions
        module Tags

          def create(serializer_options); show(serializer_options); end

          def show(serializer_options)
            serializer_options.remove_association :taggable          
          end

          def select(serializer_options); show(serializer_options); end

          def update(serializer_options); show(serializer_options); end

          def destroy(serializer_options)
          end

        end
      end
    end
  end
end