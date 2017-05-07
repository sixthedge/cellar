module Test::Serializer::Assert
  extend ActiveSupport::Concern
  included do

    # Ability.

    def assert_with_ability(json)
      assert_kind_of Hash, json, 'ability json is not a hash'
      key = ability_model_path
      assert_equal true, json.has_key?(key), "json should have abilities #{key.inspect}"
      array = json[key]  # ability array of records
      assert_kind_of Array, array, "ability json key #{key.inspect} is not an array"
      array  # can use or ignore
    end

    def assert_without_ability(json)
      key = ability_model_path
      assert_equal false, json.has_key?(key), "json should not have abilities #{key.inspect}"
    end

    def assert_with_ability_without_metadata(json)
      assert_with_ability(json)
      assert_without_metadata(json)
    end

    # Metadata.

    def assert_with_metadata(json)
      assert_kind_of Hash, json, 'ability json is not a hash'
      key = metadata_model_path
      assert_equal true, json.has_key?(key), "json should have metadata #{key.inspect}"
      array = json[key]  # metadata array of records
      assert_kind_of Array, array, "metadata json key #{key.inspect} is not an array"
      array  # can use or ignore
    end

    def assert_without_metadata(json)
      key = metadata_model_path
      assert_equal false, json.has_key?(key), "json should not have metadata #{key.inspect}"
    end

    def assert_without_ability_with_metadata(json)
      assert_without_ability(json)
      assert_with_metadata(json)
    end

    # Ability and Metadata.

    def assert_with_ability_with_metadata(json)
      assert_with_ability(json)
      assert_with_metadata(json)
    end

    def assert_without_ability_without_metadata(json)
      assert_without_ability(json)
      assert_without_metadata(json)
    end

    # Only.

    def assert_only_ability(json)
      key = ability_model_path
      assert_equal [key], json.keys
    end

    def assert_only_metadata(json)
      key = metadata_model_path
      assert_equal [key], json.keys
    end

    # Assert JSON.

    def assert_ability_json(json, records, ownerable, value, options={})
      array = assert_with_ability(json)
      assert_serializer_json(array, :abilities, records, ownerable, value, options)
    end

    def assert_metadata_json(json, records, ownerable, value, options={})
      array = assert_with_metadata(json)
      assert_serializer_json(array, :metadata, records, ownerable, value, options)
    end

    def assert_serializer_json(array, column, records, ownerable, value, options={})
      except = [options[:except]].flatten.compact
      [records].flatten.compact.each do |record|
        id  = generate_assert_id(record, ownerable)
        rec = array.find {|e| e[:id] == id}
        refute_nil rec, "record id #{id.inspect} not found"
        val = rec[column]
        assert_kind_of Hash, val, "record value #{val.inspect} is not a hash"
        assert_equal value.except(:scope), val.except(*except), "record id #{id.inspect} value [#{val.inspect}] not equal expected value [#{value.inspect}]"
      end
    end

    # Refute JSON.

    def refute_ability_json(json, records, ownerable)
      array = assert_with_ability(json)
      refute_serializer_json(array, records, ownerable)
    end

    def refute_metadata_json(json, records, ownerable)
      array = assert_with_metadata(json)
      refute_serializer_json(array, records, ownerable)
    end

    def refute_serializer_json(array, records, ownerable)
      [records].flatten.compact.each do |record|
        id  = generate_assert_id(record, ownerable)
        rec = array.find {|e| e[:id] == id}
        assert_nil rec, "record id #{id.inspect} should not have been found"
      end
    end

    # Modules.

    def assert_spaces_module_ability(json)
      array       = assert_with_ability(json)
      mod_ability = array.select {|hash| hash[:abilities] == spaces_module_ability_hash}
      refute_nil mod_ability, "spaces module ability not found"
      array  # can use or ignore
    end

    def assert_spaces_module_metadata(json)
      array        = assert_with_metadata(json)
      mod_metadata = array.select {|hash| hash[:metadata] == spaces_module_ability_hash}
      refute_nil mod_metadata, "spaces module metadata not found"
      array  # can use or ignore
    end

    # Misc.

    def assert_json_equal(jsona, jsonb)
      assert_equal jsona, jsonb, 'json should be equal'
    end

    # Helpers.

    def generate_assert_id(record, ownerable)
      "#{record.class.name.underscore}.#{record.id}::#{ownerable.class.name.underscore}.#{ownerable.id}"
    end

  end # included
end
