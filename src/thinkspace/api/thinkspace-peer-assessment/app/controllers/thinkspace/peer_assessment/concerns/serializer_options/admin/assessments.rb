module Thinkspace
  module PeerAssessment
    module Concerns
      module SerializerOptions
        module Admin
          module Assessments

            def update(serializer_options); end

            def teams(serializer_options)
              serializer_options.include_association :thinkspace_common_users, scope: :root # Root are teams.
              serializer_options.include_association :thinkspace_peer_assessment_team_sets
              serializer_options.remove_all scope: :thinkspace_common_users
            end
            
            def review_sets(serializer_options)
              serializer_options.include_association :thinkspace_peer_assessment_reviews
            end

            def team_sets(serializer_options); end
            def progress_report(serializer_options); end
            def approve_team_sets(serializer_options); end

            def approve(serializer_options)
              serializer_options.include_association :thinkspace_peer_assessment_team_sets
            end

            def activate(serializer_options)
              serializer_options.include_association :authable, scope: :root
            end

          end
        end
      end
    end
  end
end
