module Totem; module Core; module Controllers; module ApiRender; module Sort

  extend ::ActiveSupport::Concern

  included do
    def controller_sorted?; params.has_key?(:sort); end
  end

  # Order the records before processing to JSON.
  def controller_sort_records(records, options={})
    return records unless params.has_key?(:sort)
    return records unless records.respond_to?(:sort)
    sort = controller_sort_params
    return records unless sort.present?
    sort.each { |o| records = records.order(o) }
    records
  end

  def controller_sort_params
    begin
      JSON.parse(params[:sort])
    rescue JSON::ParserError => e
      nil
    end
  end

end; end; end; end; end
