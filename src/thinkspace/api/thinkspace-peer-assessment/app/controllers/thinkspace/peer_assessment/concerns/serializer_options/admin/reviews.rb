module Thinkspace; module PeerAssessment; module Concerns; module SerializerOptions; module Admin;
  module Reviews
    # Thinkspace::PeerAssessment::Concerns::SerializerOptions::Admin::Reviews
    # ---
    def approve(serializer_options); state_change(serializer_options); end
    def unapprove(serializer_options); state_change(serializer_options); end

    def state_change(serializer_options)
      serializer_options.include_association :thinkspace_peer_assessment_review_set
    end
  end
end; end; end; end; end;
