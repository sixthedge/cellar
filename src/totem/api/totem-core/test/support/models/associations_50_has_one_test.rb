require File.expand_path('../models_helper', __FILE__)

# Caution: Make sure models paths are unique in each 'it' test. Othwerwise will bleed between tests.
#          Using: model-name_filename-num (plus _model-name-unique-num-when-needed)
# Tests have been set up in the order (do not have to be in this order):
#   fn, create model classes, attributes, mocks, assoc name, args, expects, add associations

describe 'associations.rb has_one with mock serializer' do

  before do
    set_environment
    set_base_framework_serializer_class
  end

  it 'engine association paths should have valid test engines' do
    basic_association_paths_test
  end

  it '50: user.profile and profile.user' do
    fn      = '50'
    user    = path_to_class("test/associations/one/user_#{fn}")
    profile = path_to_class("test/associations/one/profile_#{fn}")
    # user.profile
    attributes = [:id, :name]
    mock       = mock_model(model: user, attributes: attributes)
    sz_mock    = mock_serializer(model: user, attributes: attributes)
    assoc_name = c_sym(profile)
    args       = {
      class_name:   profile.name,
      foreign_key:  c_foreign_key(user),
    }
    sz_args = {
      root: c_path_plural(profile),
      key:  c_path_id(profile),
    }
    mock.expect    :has_one, nil, [assoc_name, nil, args]
    sz_mock.expect :has_one, nil, [assoc_name, sz_args]
    set_mock_model_associations(mock, sz_mock, fn: fn, dir: 'value')
    # profile.user
    attributes = [:id, :settings]
    mock       = mock_model(model: profile, attributes: attributes)
    sz_mock    = mock_serializer(model: profile, attributes: attributes)
    assoc_name = c_sym(user)
    args       = {
      class_name:   user.name,
      foreign_key:  c_foreign_key(user),
    }
    sz_args = {
      root: c_path_plural(user),
      key:  c_path_id(user),
    }
    mock.expect    :belongs_to, nil, [assoc_name, nil, args]
    sz_mock.expect :has_one, nil, [assoc_name, sz_args]
    add_mock_model_associations(mock, sz_mock)
  end

  it '51: cross-path user.profile and profile.user' do
    fn      = '51'
    user    = path_to_class("test/associations/one/user_#{fn}")
    profile = path_to_class("test/associations/two/profile_#{fn}")
    # user.profile
    attributes = [:id, :name]
    mock       = mock_model(model: user, attributes: attributes)
    sz_mock    = mock_serializer(model: user, attributes: attributes)
    assoc_name = c_sym(profile)
    args       = {
      class_name:   profile.name,
      foreign_key:  c_foreign_key(user),
    }
    sz_args = {
      root: c_path_plural(profile),
      key:  c_path_id(profile),
    }
    mock.expect    :has_one, nil, [assoc_name, nil, args]
    sz_mock.expect :has_one, nil, [assoc_name, sz_args]
    set_mock_model_associations(mock, sz_mock, fn: fn, dir: 'value')
    # profile.user
    attributes = [:id, :settings]
    mock       = mock_model(model: profile, attributes: attributes)
    sz_mock    = mock_serializer(model: profile, attributes: attributes)
    assoc_name = c_sym(user)
    args       = {
      class_name:   user.name,
      foreign_key:  c_foreign_key(user),
    }
    sz_args = {
      root: c_path_plural(user),
      key:  c_path_id(user),
    }
    mock.expect    :belongs_to, nil, [assoc_name, nil, args]
    sz_mock.expect :has_one, nil, [assoc_name, sz_args]
    add_mock_model_associations(mock, sz_mock)
  end

  it '52: polymorphic' do
    fn         = '52'
    user       = path_to_class("test/associations/one/user_#{fn}")
    profile    = path_to_class("test/associations/one/profile_#{fn}")
    attributes = [:id, :name, :email]
    mock       = mock_model(model: user, attributes: attributes)
    sz_mock    = mock_serializer(model: user, attributes: attributes)
    assoc_name = c_sym(profile)
    args       = {
      class_name: profile.name,
      as:         'polymorphicable',
    }
    sz_args = {
      root: c_path_plural(profile),
      key:  c_path_id(profile),
    }
    mock.expect    :has_one, nil, [assoc_name, nil, args]
    sz_mock.expect :has_one, nil, [assoc_name, sz_args]
    set_mock_model_associations(mock, sz_mock, fn: fn, dir: 'value')
  end

  it '52a: polymorphic - profile without serializer' do
    fn         = '52a'
    user       = path_to_class("test/associations/one/user_#{fn}")
    profile    = path_to_class("test/associations/one/profile_#{fn}")
    attributes = [:id, :name, :email]
    mock       = mock_model(model: user, attributes: attributes)
    sz_mock    = mock_serializer(model: user, attributes: attributes)
    assoc_name = c_sym(profile)
    args       = {
      class_name: profile.name,
      as:         'polymorphicable',
    }
    sz_args = {
      root: c_path_plural(profile),
      key:  c_path_id(profile),
    }
    mock.expect    :has_one, nil, [assoc_name, nil, args]
    sz_mock.expect :has_one, nil, [assoc_name, sz_args]
    e = assert_raises(MockExpectationError) do  # raised since missing serializer
      set_mock_model_associations(mock, sz_mock, fn: fn, dir: 'value')
    end
    assert_match(/expected has_one.*got/i, e.to_s)
  end

  it '53: self alias' do
    fn         = '53'
    user       = path_to_class("test/associations/one/user_#{fn}")
    attributes = [:id, :name, :email]
    mock       = mock_model(model: user, attributes: attributes)
    sz_mock    = mock_serializer(model: user, attributes: attributes)
    assoc_name = :test_associations_one_parent
    args       = {
      primary_key: 'parent_id',
      foreign_key: 'id',
      class_name:  user.name,
    }
    sz_args = {
      root: 'test/associations/one/user53s',
      key:  'test/associations/one/parent_id',
    }
    mock.expect    :has_one, nil, [assoc_name, nil, args]
    sz_mock.expect :has_one, nil, [assoc_name, sz_args]
    set_mock_model_associations(mock, sz_mock, fn: fn, dir: 'value')
  end

  it '54: user.account.where(active => true).readonly and accepts_nested_attributes_for' do
    fn         = '54'
    user       = path_to_class("test/associations/one/user_#{fn}")
    account    = path_to_class("test/associations/one/account_#{fn}")
    attributes = [:id, :name, :email]
    mock       = mock_model(model: user, attributes: attributes)
    sz_mock    = mock_serializer(model: user, attributes: attributes)
    assoc_name = c_sym(account)
    args       = {
      class_name:  account.name,
      foreign_key: c_foreign_key(user),
    }
    sz_args = {
      root: c_path_plural(account),
      key:  c_path_id(account),
    }
    expect_model_association_with_scope(mock,
      method:     :has_one,
      fn:         fn,
      assoc_name: assoc_name,
      args:       args,
      scopes:     {where: {active: true}, readonly: nil},
    )
    mock.expect    :accepts_nested_attributes_for, nil, [c_sym_plural(account), {allow_destroy: true}]
    sz_mock.expect :has_one, nil, [assoc_name, sz_args]
    set_mock_model_associations(mock, sz_mock, fn: fn, dir: 'value')
  end

  it '58: most options - not polymorphic' do
    fn         = '58'
    user       = path_to_class("test/associations/one/user_#{fn}")
    attributes = [:id, :name, :email, :another]
    mock       = mock_model(model: user, attributes: attributes)
    sz_mock    = mock_serializer(model: user, attributes: attributes)
    assoc_name = :test_associations_one_some_alias
    args       = {
      class_name:   'Test::Associations::One::User58',
      polymorphic:  false,
      foreign_key:  'foreign_key_override',
      foreign_type: 'foreign_type_override',
      primary_key:  'primary_key_override',
      dependent:    :dependent_value,
      validate:     'validate_value',
      autosave:     'autosave_value',
      touch:        :mydate_at,
      inverse_of:   :some_inverse_association,
      bad_option:   'bad_option_still_included',
    }
    sz_args = {
      root:        c_path_plural(user),
      key:         'test/associations/one/some_alias_id',
      polymorphic: false,
    }
    expect_model_association_with_scope(mock,
      method:     :has_one,
      fn:         fn,
      assoc_name: assoc_name,
      args:       args,
      scopes:     {order: 'name', readonly: nil},
    )
    mock.expect    :accepts_nested_attributes_for, nil, [c_sym_plural(user), {key: 'value'}]
    sz_mock.expect :has_one, nil, [assoc_name, sz_args]
    set_mock_model_associations(mock, sz_mock, fn: fn, dir: 'value')
  end

  it '59: most options - polymorphic' do
    fn         = '59'
    user       = path_to_class("test/associations/one/user_#{fn}")
    account    = path_to_class("test/associations/one/account_#{fn}")
    attributes = [:id, :name, :email, :another]
    mock       = mock_model(model: user, attributes: attributes)
    sz_mock    = mock_serializer(model: user, attributes: attributes)
    assoc_name = :test_associations_one_some_alias
    args       = {
      class_name:   account.name,
      as:           'polymorphicable',
      foreign_key:  'foreign_key_override',
      foreign_type: 'foreign_type_override',
      primary_key:  'primary_key_override',
      dependent:    :dependent_value,
      validate:     'validate_value',
      autosave:     'autosave_value',
      touch:        :mydate_at,
      inverse_of:   :some_inverse_association,
      bad_option:   'bad_option_still_included',
    }
    sz_args = {
      root: c_path_plural(account),
      key:  'test/associations/one/some_alias_id',
    }
    expect_model_association_with_scope(mock,
      method:     :has_one,
      fn:         fn,
      assoc_name: assoc_name,
      args:       args,
      scopes:     {order: 'name', readonly: nil},
    )
    sz_mock.expect :has_one, nil, [assoc_name, sz_args]
    set_mock_model_associations(mock, sz_mock, fn: fn, dir: 'value')
  end

end
