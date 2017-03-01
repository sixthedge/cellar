module Totem; module Core; module Controllers; module ApiRender; module Paginate

  extend ::ActiveSupport::Concern

  included do
    def controller_paginated?; params.has_key?(:page); end
  end

  # Return paginated JSON format.
  def controller_paginated_json(records, options={})
    controller_as_paginated_json(records, options)
  end

  def controller_as_paginated_json(records, options)
    all_records                     = records
    records                         = controller_paginate(records, options)
    options[:serialization_context] = ActiveModelSerializers::SerializationContext.new(request)
    options[:meta]                  = controller_pagination_get_meta_for_records(all_records)
    json                            = controller_as_json(records, options)
    json
  end

  def controller_paginate(records, options)
    number = controller_pagination_get_number
    size   = controller_pagination_get_size 
    records.page(number).per(size)
  end

  def controller_pagination_links_key; 'links'; end
  def controller_pagination_meta_key; 'meta'; end

  def controller_pagination_get_meta_for_records(records)
    meta                   = Hash.new
    meta[:page]            = Hash.new
    meta[:records]         = Hash.new
    total_pages            = (records.length.to_f / controller_pagination_get_size).ceil
    total_pages            == 0 ? current_page = 0 : current_page = controller_pagination_get_number
    meta[:page][:total]    = total_pages
    meta[:page][:current]  = current_page
    meta[:records][:total] = records.length
    meta
  end

  def controller_pagination_get_number; params[:page][:number].to_i || 0; end
  def controller_pagination_get_size;  params[:page][:size].to_i  || 25; end

end; end; end; end; end
