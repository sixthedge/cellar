module Thinkspace; module PeerAssessment; module Concerns; module SerializerOptions; module Admin;
  # Thinkspace::PeerAssessment::Concerns::SerializerOptions::Admin::ReviewSets
  # ---
  module ReviewSets
    def ignore(serializer_options); state_change(serializer_options); end
    def unignore(serializer_options); state_change(serializer_options); end
    def complete(serializer_options); state_change(serializer_options); end
    def unlock(serializer_options); end
    def remind(serializer_options); end

    def state_change(serializer_options)
      serializer_options.include_association :thinkspace_peer_assessment_reviews
    end
  end
end; end; end; end; end;
