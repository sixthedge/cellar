module Thinkspace; module Report
class File < ActiveRecord::Base
  has_attached_file                    :attachment, s3_permissions: :private
  do_not_validate_attachment_file_type :attachment

  def title
    attachment_file_name
  end

  def content_type
    attachment_content_type
  end

  def size
    attachment_file_size
  end

  def url
    attachment.expiring_url(15.minutes.to_i)
  end

  # ### Paperclip
  def paperclip_path
    default = "spaces/system/reports/:filename"
    report = thinkspace_report_report
    return default unless report.present?
    authable = report.authable
    return default unless authable.present?
    return default unless authable.respond_to?(:thinkspace_common_space)
    space = authable.thinkspace_common_space
    return default unless space.present?
    return "spaces/#{space.id}/reports/:filename"
  end

  totem_associations

end; end; end