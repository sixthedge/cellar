module Thinkspace; module PeerAssessment; module Concerns; module SerializerOptions; module Admin;
  # # admin/reviews
  # - Type: **Concerns** - **Serializer Options**
  # - Engine: **thinkspace-peer-assessment**
  module Reviews
    def approve(serializer_options); state_change(serializer_options); end
    def unapprove(serializer_options); state_change(serializer_options); end

    def state_change(serializer_options)
      serializer_options.include_association :thinkspace_peer_assessment_review_set
    end
  end
end; end; end; end; end;
