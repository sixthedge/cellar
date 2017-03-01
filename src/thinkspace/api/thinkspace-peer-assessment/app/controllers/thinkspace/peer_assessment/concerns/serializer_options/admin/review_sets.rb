module Thinkspace
  module PeerAssessment
    module Concerns
      module SerializerOptions
        module Admin
          module ReviewSets

            def approve(serializer_options); state_change(serializer_options); end
            def unapprove(serializer_options); state_change(serializer_options); end
            def notify(serializer_options); end

            def state_change(serializer_options)
              serializer_options.include_association :thinkspace_peer_assessment_reviews
            end
            
          end
        end
      end
    end
  end
end
