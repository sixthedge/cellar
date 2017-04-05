module Thinkspace; module PeerAssessment
  class Overview < ActiveRecord::Base
    # Thinkspace::PeerAssessment::Overview
    # ---
    totem_associations

    include ::Totem::Settings.module.thinkspace.deep_clone_helper

    def cyclone(options={})
      self.transaction do
        cloned_overview = clone_self(options)

        assessment = self.thinkspace_peer_assessment_assessment
        if assessment.present?
          dictionary        = get_clone_dictionary(options)
          cloned_assessment = get_cloned_record_from_dictionary(assessment, dictionary)
        end

        cloned_overview.assessment_id = cloned_assessment.present? ? cloned_assessment.id : nil
        clone_save_record(cloned_overview)
      end
    end

  end
end; end;