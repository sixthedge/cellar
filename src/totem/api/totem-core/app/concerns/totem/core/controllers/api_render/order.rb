module Totem; module Core; module Controllers; module ApiRender; module Order

  extend ::ActiveSupport::Concern

  included do
    def controller_ordered?; params.has_key?(:order); end
  end

  # Order the records before processing to JSON.
  def controller_order_records(records, options={})
    return records unless params.has_key?(:order)
    return records unless records.respond_to?(:order)
    order = controller_order_params
    return records unless order.present?
    order.each { |o| records = records.order(o) }
    records
  end

  def controller_order_params
    begin
      JSON.parse(params[:order])
    rescue JSON::ParserError => e
      nil
    end
  end

end; end; end; end; end
