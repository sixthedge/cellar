module Totem; module Core; module Controllers; module ApiRender; module AfterJson

  extend ::ActiveSupport::Concern

  included do
    def controller_after_json?; serializer_options_defined?; end
  end

  def controller_after_json(json, options={})
    case
    when serializer_options.collect_exists?
      serializer_options.collect_module_data
      controller_add_collect_data_to_json(serializer_options.collect_keys, json)
    end
  end

end; end; end; end; end
