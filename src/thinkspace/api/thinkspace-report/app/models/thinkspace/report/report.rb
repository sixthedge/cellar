module Thinkspace; module Report
class Report < ActiveRecord::Base

  # ### Scopes
  def self.scope_order_by_created_at
    order(created_at: :desc)
  end

  def self.scope_valid
    joins(:thinkspace_report_report_tokens).
    where('thinkspace_report_report_tokens.expires_at > ?', Time.now)
  end

  def self.scope_group_by_report_id
    group('thinkspace_report_reports.id')
  end

  def self.scope_for_index
    scope_order_by_created_at.
    scope_valid.
    scope_group_by_report_id
  end

  # ### Scoped attributes
  def token(scope)
    report_token = thinkspace_report_report_tokens.where(thinkspace_common_user: scope.current_user).scope_valid.first
    report_token.present? ? report_token.token : nil
  end

  def generate
    user = get_user
    return send_error_notification('INVALID_USER') unless user.present? && user.email.present?

    case get_type
    when 'ownerable_data'
      # TODO: Add a mapping from a type to a class in the future for more types.
      klass = Thinkspace::Casespace::Exporters::OwnerableData
    else
      return send_error_notification('INVALID_REPORT_TYPE')
    end
    klass.present? ? klass.generate(self) : send_error_notification('INVALID_CLASS')
  end
  handle_asynchronously :generate

  # ### File helpers
  def add_file(options)
    file           = Thinkspace::Report::File.new(options)
    file.user_id   = self.user_id
    file.report_id = self.id
    file.save ? true : false
  end

  # ### Notifications
  def send_access_notification
    report_token = generate_report_token
    report_token.notify_user
  end

  # ### ReportToken helpers
  def generate_report_token
    Thinkspace::Report::ReportToken.create_for_report(self)
  end

  # ### Getter helpers
  def get_type; value['type']; end

  def get_humanized_type
    type = get_type || ''
    type.humanize
  end

  def get_user; thinkspace_common_user; end

  def get_title_from_type
    case get_type
    when 'ownerable_data'
      "#{authable.title} - Score and Response Data - #{Time.now}"
    else
      'Unknown Report'
    end
  end

  # ### Error handling
  def send_error_notification(error_code, message='There has been an error when generating your report.')
    puts "\n\n\n"
    puts "ERROR CODE=#{error_code}"
    puts "\n\n\n"
    raise message
    # NO_AUTH: No authable found in report.
    # AUTH_NO_RESP: Authable does not respond to an exporter expected method.
    # NO_BOOK_FOR_AUTH: No valid book from exporter for the given authable.
    # FILE_SAVE_FAIL: Adding a file to the report failed.
    # INVALID_CLASS: No class specified for generation.
    # INVALID_USER: No user or email assigned to report.
    # INVALID_REPORT_TYPE: The report_type was not known by the system.
    Thinkspace::Report::NotificationMailer.report_generation_failed(self, error_code, message).deliver_now
  end

  # ### Misc.
  totem_associations

end; end; end
