module Test; module Controller; module TestAction

  extend ActiveSupport::Concern
  included do

  it "..correct json models..#{@username}#{@route.test_it_name}" do
    hash = send_route_request
    assert_equal json_model_keys, hash.keys.sort, 'json includes only the correct models'
  end

  it "..ids are the same..#{@username}#{@route.test_it_name}" do
    hash  = send_route_request
    blank = get_let_value_array(:json_blank)
    json_models.each do |name|
      actual = json_column(hash, name, :id)
      if blank.include?(name)
        assert_equal [], actual, "#{name.inspect} json key should be an empty array"
      else
        assert_equal extract_db_column(name, :id), actual, "#{name.inspect} model ids are equal in json and db"
      end
    end
  end

end; end; end; end
