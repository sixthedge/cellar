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

  totem_associations

end; end; end