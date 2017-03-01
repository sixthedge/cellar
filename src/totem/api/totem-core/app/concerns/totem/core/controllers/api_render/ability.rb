module Totem; module Core; module Controllers; module ApiRender; module Ability

  def controller_ability_model_path; controller_ability_class_name.underscore; end

  def controller_ability_add_to_json(json)
    controller_ability_set_in_json(json, controller_ability_json)
  end

  def controller_ability_set_in_json(json, ability_json)
    return if ability_json.blank?
    # data = json[:data].blank? ? (json[:data] ||= Array.new) : (json[:included] ||= Array.new)
    data = (json[:included] ||= Array.new)
    ability_json.each {|a| data.push(a)}
    serializer_options.clear_collect_ability
  end

  def controller_ability_json
    ownerable      = serializer_options.collect_data_ownerable
    ownerable_id   = ownerable.id
    ownerable_type = ownerable.class.name.underscore
    json           = Array.new
    type           = controller_ability_model_path
    serializer_options.collect_ability_data.each do |hash|
      id  = hash[:type].present? ? "#{hash[:type]}.#{hash[:id]}" : "#{hash[:id]}"
      id += "::#{ownerable_type}.#{ownerable_id}"
      json.push({id: id, type: type, attributes: {abilities: hash[:data]}})
    end
    json
  end

end; end; end; end; end
