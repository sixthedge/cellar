require File.expand_path('../models_helper', __FILE__)

# Caution: Make sure models paths are unique in each 'it' test. Othwerwise will bleed between tests.
#          Using: model-name_filename-num (plus _model-name-unique-num-when-needed)

describe 'associations.rb with actual serializer e.g. not mocked' do

  before do
    set_environment
    set_base_framework_serializer_class
  end

  it 'engine association paths should have valid test engines' do
    basic_association_paths_test
  end

  it '01: one/user and two/user with belongs_to; serializer auto-generated' do
    fn         = '01'
    user_one   = path_to_class("test/associations/one/user_#{fn}_01")
    user_two   = path_to_class("test/associations/two/user_#{fn}_02")
    attributes = [:id, :name]
    mock       = mock_model(model: user_one, attributes: attributes)
    assoc_name = c_sym(user_two)
    args       = {
      class_name:   user_two.name,
      foreign_key:  c_foreign_key(user_two),
    }
    mock.expect :belongs_to, nil, [assoc_name, nil, args]
    set_mock_model_associations(mock, fn: fn, dir: 'value')
    sz = 'Test::Associations::One::User0101Serializer'.safe_constantize
    refute_nil sz, 'User::Serializer should be present.'
    assert_kind_of base_serializer_class, sz.new({})
    expect = {c_sym(user_two)=>[ActiveModel::Serializer::Association::HasOne, {root: c_path_plural(user_two), key: c_path_id(user_two)}]}
    assert_equal expect, sz.totem_associations
  end

end
