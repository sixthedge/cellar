module Totem; module Core; module Controllers; module ApiRender; module JsonApiIncluded

  # Render records in json-api format array.  e.g. {included: [{id: 1, type: 'thinkspace/common/user', attributes: {}}, ...]}
  def controller_render_included(records, options={})
    controller_render_json controller_json_api_included(records, options)
  end

  def controller_json_api_included(records, options={})
    key      = options[:root_key] || :included
    hash     = Hash.new
    included = hash[key] = Array.new
    [records].flatten.compact.each do |record|
      include_hash = {
        id:         record.id,
        type:       record.class.name.underscore,
        attributes: record.attributes,
      }
      included.push(include_hash)
    end
    hash
  end

end; end; end; end; end
