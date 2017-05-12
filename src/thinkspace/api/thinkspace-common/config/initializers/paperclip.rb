# Interpolation additions
Paperclip.interpolates :paperclip_path do |attachment, style|
  path   = attachment.instance.paperclip_path.sub(/\/$/, '')
  result = path.dup
  path.scan(/:[a-zA-Z]*/).each do |i|
    method = i.sub(':', '')
    return unless self.respond_to?(method)
    value  = send(method, attachment, style) || ''
    result.gsub!(/#{i}/, value)
  end
  result
end

# For localstore, add in the public paths to the paperclip path.
Paperclip.interpolates :dev_paperclip_path do |attachment, style|
  path = paperclip_path(attachment, style).sub(/\/$/, '')
  "public/paperclip/#{path}"
end

Paperclip.interpolates :dev_url_path do |attachment, style|
  result = dev_paperclip_path(attachment, style).sub(/^public\//,'')
  host   = Rails.application.secrets.host || 'localhost'
  "http://#{host}:3000/#{result}"
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
