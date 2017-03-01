# Interpolation additions
Paperclip.interpolates :resourceable_path do |attachment, style|
  "#{attachment.instance.resourceable_type.split('::').last.downcase}/#{attachment.instance.resourceable_id}"
end

Paperclip.interpolates :ownerable_path do |attachment, style|
  "#{attachment.instance.ownerable_type.split('::').last.downcase}/#{attachment.instance.ownerable_id}"
end

Paperclip.interpolates :numeric_timestamp do |attachment, style|
  "#{attachment.instance.created_at.to_i}"
end

Paperclip.interpolates :artifact_path do |attachment, style|
  phase      = attachment.instance.thinkspace_artifact_bucket.authable
  ownerable  = attachment.instance.ownerable
  assignment = phase.thinkspace_casespace_assignment
  space      = assignment.thinkspace_common_space
  if ownerable.respond_to?(:email)
    ownerable_name = ownerable.email.parameterize
  else
    ownerable_name = "#{ownerable.class.name}-#{ownerable.id}".parameterize
  end
  "space/#{space.id}/assignment/#{assignment.id}/phase/#{phase.id}/#{ownerable_name}"
end

# Override type detection temporarily until a better work around can be implemented.
require 'paperclip/media_type_spoof_detector'
module Paperclip
 class MediaTypeSpoofDetector
    def spoofed?
      false
    end
  end
end