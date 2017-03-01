module Thinkspace; module Report; module Concerns; module SerializerOptions
module Reports

  def common(so)
    so.remove_association :thinkspace_report_report_tokens
    so.remove_association :thinkspace_report_files
  end

  def index(so);    common(so); end
  def generate(so); common(so); end
  def access(so)
    so.remove_association  :thinkspace_report_report_tokens
    so.include_association :thinkspace_report_files
  end
  def destroy(so); common(so); end

end; end; end; end; end 