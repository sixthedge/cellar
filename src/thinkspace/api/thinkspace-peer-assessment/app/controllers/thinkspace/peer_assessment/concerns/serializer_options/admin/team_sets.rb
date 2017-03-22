module Thinkspace; module PeerAssessment; module Concerns; module SerializerOptions; module Admin;
  # # admin/team_sets
  # - Type: **Concerns** - **Serializer Options**
  # - Engine: **thinkspace-peer-assessment**  
  module TeamSets
    def approve(serializer_options); state_change(serializer_options); end
    def unapprove(serializer_options); state_change(serializer_options); end
    def approve_all(serializer_options); state_change(serializer_options); end
    def unapprove_all(serializer_options); state_change(serializer_options); end
    def show(serializer_options); state_change(serializer_options); end

    def state_change(serializer_options)
      serializer_options.include_association :thinkspace_peer_assessment_review_sets
      serializer_options.include_association :thinkspace_peer_assessment_reviews, scope: :thinkspace_peer_assessment_review_sets
    end
  end
end; end; end; end; end;
