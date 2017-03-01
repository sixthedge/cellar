require File.expand_path('../routes_helper', __FILE__)

describe 'routes.rb invalid' do

  before do
    set_mock_mapper
    set_routes_invalid
  end

  it 'no route error' do
    e = assert_raises(RuntimeError) do
      @routes.call(@mock_mapper, route: '')
    end
    assert_match(/invalid route/i, e.to_s)
  end

  it 'route not starting with * error' do
    e = assert_raises(RuntimeError) do
      @routes.call(@mock_mapper, route: 'invalid')
    end
    assert_match(/start with/i, e.to_s)
  end

  it 'route cannot be * error' do
    e = assert_raises(RuntimeError) do
      @routes.call(@mock_mapper, route: '*')
    end
    assert_match(/be only/i, e.to_s)
  end

  it 'adds invalid route' do
    @mock_mapper.expect(:match, nil) do |match, hash|
      to = hash[:to].call(nil)  # get the result of the proc
      match == '*invalid' &&
      hash[:via] == :all  &&
      assert_equal([404, {}, ["{\"error\":\"invalid request\"}"]], to)
    end
    @routes.call(@mock_mapper)
    @mock_mapper.verify
  end

  it 'adds invalid route with options' do
    @mock_mapper.expect(:match, nil) do |match, hash|
      to = hash[:to].call(nil)  # get the result of the proc
      match == '*mybad' &&
      hash[:via] == [:get, :post] &&
      assert_equal([444, {}, ["{\"error\":\"message override\"}"]], to)
    end
    @routes.call(@mock_mapper, route: '*mybad', status: 444, via: [:get, :post], error_message: 'message override')
    @mock_mapper.verify
  end

end
