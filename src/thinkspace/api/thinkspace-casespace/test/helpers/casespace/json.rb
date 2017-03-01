module Test::Casespace::Json
  extend ActiveSupport::Concern
  included do

    def extract_json(hash, primary_key, key)
      return nil unless hash.has_key?(primary_key)
      array = hash[primary_key]
      json = [array].flatten.collect {|h| h[key.to_s]}
      json.present? && json.first.kind_of?(Hash) ? json : json.sort
    end

    def extract_json_users(hash, key=:first_name)
      primary_key = 'thinkspace/common/users'
      primary_key = 'thinkspace/common/user'  unless hash.has_key?(primary_key)
      actual      = extract_json(hash, primary_key, key)
      key == :first_name ? actual.map {|name| name.to_sym} : actual.flatten
    end

    def extract_json_spaces(hash, key=:title)
      primary_key = 'thinkspace/common/spaces'
      primary_key = 'thinkspace/common/space'  unless hash.has_key?(primary_key)
      actual      = extract_json(hash, primary_key, key)
      key == :title ? actual.map {|title| title.to_sym} : actual.flatten
    end

    # ###
    # ### Json Keys.
    # ###

    def json_model_keys; get_let_value_array(:json_models).map {|name| json_key(name)}.sort; end

    def json_column(hash, name, col); extract_json(hash, json_key(name), col); end

    def json_key(name); json_model_class_name(name).underscore; end

    # If the key is in the same namespace as the controller, can pass just the name (e.g. :phase).
    # Otherwise need the full path (e.g. 'thinkspace/common/user').
    def json_model_class_name(name)
      name = name.to_s
      return name.camelize  if name.match('/')
      get_controller_model_class_name.deconstantize + "::#{name.camelize}"
    end

    # ###
    # ### Json Related Extract Route Model Records.
    # ###

    def extract_db_column(name, col); extract_column(json_route_model_records(name), col); end

    def extract_column(records, col)
      col    = col.to_sym
      actual = [records].flatten.collect {|h| h && h[col]}.sort.compact
      [:first_name, :title].include?(col) ? actual.map {|value| value.to_sym} : actual
    end

    # If a let value with the name "#{name}_scope" exists, return the scope,
    # otherwise get the model or model's association.
    def json_route_model_records(name)
      sname = name.to_s.singularize
      scope = get_let_value("#{sname}_scope")
      return scope unless scope.nil?
      model = @route.model
      return nil if model.blank?
      class_name = json_model_class_name(sname)
      return model if is_controller_model?(class_name)
      get_model_association_records_by_class_name(model, class_name)
    end

  end # included
end
