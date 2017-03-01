require File.expand_path('../models_helper', __FILE__)

# Caution: Make sure models paths are unique in each 'it' test. Othwerwise will bleed between tests.
#          Using: model-name_filename-num (plus _model-name-unique-num-when-needed)
# Tests have been set up in the order (do not have to be in this order):
#   fn, create model classes, attributes, mocks, assoc name, args, expects, add associations

def mock_error_model
  mock = MiniTest::Mock.new
  mock.expect :ancestors, [ActiveRecord::Base]
  mock.expect :blank?, false
  mock
end

describe 'associations errors' do

  before do
    set_environment
    set_base_framework_serializer_class
  end

  it 'engine association paths should have valid test engines' do
    basic_association_paths_test
  end

  it 'model class is blank' do
    e = assert_raises(RuntimeError) do
      set_mock_model_associations
    end
    assert_match(/model.*blank/i, e.to_s)
  end

  it 'class does not extend active record base' do
    model = path_to_class('test/associations/one/user')
    e = assert_raises(RuntimeError) do
      set_mock_model_associations(model)
    end
    assert_match(/not a subclass.*ActiveRecord::Base/i, e.to_s)
  end

  it 'no associations.yml file' do
    mock = mock_error_model
    e = assert_raises(RuntimeError) do
      set_mock_model_associations(mock, {})
    end
    assert_match(/associations file.*not exist/i, e.to_s)
  end

  it '10: associations.yml not an array' do
    fn   = '10'
    mock = mock_error_model
    e = assert_raises(RuntimeError) do
      set_mock_model_associations(mock, fn: fn, dir: 'error')
    end
    assert_match(/associations file.*not.*valid format/i, e.to_s)
  end

  it '11: associations.yml model values not a hash' do
    fn   = '11'
    mock = mock_error_model
    e = assert_raises(RuntimeError) do
      set_mock_model_associations(mock, fn: fn, dir: 'error')
    end
    assert_match(/model association.*not.*valid format/i, e.to_s)
  end

  it '12: no current platform name for model' do
    fn   = '12'
    mock = mock_error_model
    e = assert_raises(RuntimeError) do
      set_mock_model_associations(mock, fn: fn, dir: 'error')
    end
    assert_match(/not determine engine name for path/i, e.to_s)
  end

  it '13a: unknown model platform scope' do
    fn   = '13'
    mock = mock_error_model
    e = assert_raises(RuntimeError) do
      set_associations_filename('error', fn)
      configs = @env.registered.instance_variable_get('@engine_configurations')
      configs['test_associations_two']['platform_scope'] = ''
      add_mock_model_associations(mock)
    end
    assert_match(/not determine platform scope/i, e.to_s)
  end

  it '13b: unknown model platform name' do
    fn   = '13'
    mock = mock_error_model
    e = assert_raises(RuntimeError) do
      set_associations_filename('error', fn)
      configs = @env.registered.instance_variable_get('@engine_configurations')
      configs['test_associations_two']['platform_scope'] = 'another'
      configs['test_associations_two']['platform_name'] = ''
      add_mock_model_associations(mock)
    end
    assert_match(/not determine platform name/i, e.to_s)
  end

  it '14: unknown model association type' do
    fn   = '14'
    mock = mock_error_model
    e = assert_raises(RuntimeError) do
      set_mock_model_associations(mock, fn: fn, dir: 'error')
    end
    assert_match(/unknown model association type/i, e.to_s)
  end

  it '15: missing model definition' do
    fn   = '15'
    user = path_to_class("test/associations/one/error_user_#{fn}")
    mock = mock_error_model
    mock_expect_ntimes(mock, :name, user.name, [], 2)
    e = assert_raises(RuntimeError) do
      set_mock_model_associations(mock, fn: fn, dir: 'error')
    end
    assert_match(/missing model association definition/i, e.to_s)
  end

  it '16: cannot constantize serailizer class' do
    fn         = '16'
    user       = path_to_class("test/associations/one/error_user_#{fn}")
    attributes = [:id, :name]
    mock       = mock_model(model: user, attributes: attributes)
    e = assert_raises(RuntimeError) do
      set_mock_model_associations(mock, fn: fn, dir: 'error')
    end
    assert_match(/cannot constantize.*serializer/i, e.to_s)
  end

  it '17: duplicate serailizer class' do
    fn         = '17'
    user       = path_to_class("test/associations/one/error_user_#{fn}")
    attributes = [:id, :name]
    mock       = mock_model(model: user, attributes: attributes)
    e = assert_raises(RuntimeError) do
      set_mock_model_associations(mock, fn: fn, dir: 'error')
    end
    assert_match(/serializer class.*duplicate/i, e.to_s)
  end

  it '18: unknown serializer association' do
    fn         = '18'
    user       = path_to_class("test/associations/one/error_user_#{fn}")
    attributes = [:id, :name]
    mock       = mock_model(model: user, attributes: attributes)
    e = assert_raises(RuntimeError) do
      set_mock_model_associations(mock, fn: fn, dir: 'error')
    end
    assert_match(/unknown serializer association/i, e.to_s)
  end

end
