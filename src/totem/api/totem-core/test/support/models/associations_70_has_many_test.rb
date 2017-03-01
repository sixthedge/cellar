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

  it '70: account.users' do
    fn      = '70'
    account = path_to_class("test/associations/one/account_#{fn}")
    user    = path_to_class("test/associations/one/user_#{fn}")
    attributes = [:id, :title]
    mock       = mock_model(model: account, attributes: attributes)
    sz_mock    = mock_serializer(model: account, attributes: attributes)
    assoc_name = c_sym_plural(user)
    args       = {
      class_name:   user.name,
      foreign_key:  c_foreign_key(account),
    }
    sz_args = {
      root: c_path_plural(user),
      key:  c_path_ids(user),
    }
    mock.expect    :has_many, nil, [assoc_name, nil, args]
    sz_mock.expect :has_many, nil, [assoc_name, sz_args]
    set_mock_model_associations(mock, sz_mock, fn: fn, dir: 'value')
  end

  it '71: cross-path account.users' do
    fn      = '71'
    account = path_to_class("test/associations/one/account_#{fn}")
    user    = path_to_class("test/associations/two/user_#{fn}")
    attributes = [:id, :title]
    mock       = mock_model(model: account, attributes: attributes)
    sz_mock    = mock_serializer(model: account, attributes: attributes)
    assoc_name = c_sym_plural(user)
    args       = {
      class_name:   user.name,
      foreign_key:  c_foreign_key(account),
    }
    sz_args = {
      root: c_path_plural(user),
      key:  c_path_ids(user),
    }
    mock.expect    :has_many, nil, [assoc_name, nil, args]
    sz_mock.expect :has_many, nil, [assoc_name, sz_args]
    set_mock_model_associations(mock, sz_mock, fn: fn, dir: 'value')
  end

  it '72: account.users polymorphic' do
    fn         = '72'
    account = path_to_class("test/associations/one/account_#{fn}")
    user    = path_to_class("test/associations/one/user_#{fn}")
    attributes = [:id, :title]
    mock       = mock_model(model: account, attributes: attributes)
    sz_mock    = mock_serializer(model: account, attributes: attributes)
    assoc_name = c_sym_plural(user)
    args       = {
      class_name: user.name,
      as:         'polymorphicable',
    }
    sz_args = {
      root: c_path_plural(user),
      key:  c_path_ids(user),
    }
    mock.expect    :has_many, nil, [assoc_name, nil, args]
    sz_mock.expect :has_many, nil, [assoc_name, sz_args]
    set_mock_model_associations(mock, sz_mock, fn: fn, dir: 'value')
  end

  it '73: self alias' do
    fn         = '73'
    user       = path_to_class("test/associations/one/user_#{fn}")
    attributes = [:id, :name, :email]
    mock       = mock_model(model: user, attributes: attributes)
    sz_mock    = mock_serializer(model: user, attributes: attributes)
    assoc_name = :test_associations_one_parents
    args       = {
      primary_key: 'parent_id',
      foreign_key: 'id',
      class_name:  user.name,
    }
    sz_args = {
      root: c_path_plural(user),
      key:  'test/associations/one/parent_ids',
    }
    mock.expect    :has_many, nil, [assoc_name, nil, args]
    sz_mock.expect :has_many, nil, [assoc_name, sz_args]
    set_mock_model_associations(mock, sz_mock, fn: fn, dir: 'value')
  end

  it '74: account.users.where(active => true).readonly and accepts_nested_attributes_for' do
    fn         = '74'
    account    = path_to_class("test/associations/one/account_#{fn}")
    user       = path_to_class("test/associations/one/user_#{fn}")
    attributes = [:id, :title]
    mock       = mock_model(model: account, attributes: attributes)
    sz_mock    = mock_serializer(model: account, attributes: attributes)
    assoc_name = c_sym_plural(user)
    args       = {
      class_name:  user.name,
      foreign_key: c_foreign_key(account),
    }
    sz_args = {
      root: c_path_plural(user),
      key:  c_path_ids(user),
    }
    expect_model_association_with_scope(mock,
      method:     :has_many,
      fn:         fn,
      assoc_name: assoc_name,
      args:       args,
      scopes:     {where: {active: true}, readonly: nil},
    )
    mock.expect    :accepts_nested_attributes_for, nil, [c_sym_plural(user), {allow_destroy: true}]
    sz_mock.expect :has_many, nil, [assoc_name, sz_args]
    set_mock_model_associations(mock, sz_mock, fn: fn, dir: 'value')
  end

  it '75: account.users through account_users' do
    fn            = '75'
    account       = path_to_class("test/associations/one/account_#{fn}")
    user          = path_to_class("test/associations/one/user_#{fn}")
    account_users = path_to_class("test/associations/one/account_users_#{fn}")
    attributes    = [:id, :title]
    mock          = mock_model(model: account, attributes: attributes)
    sz_mock       = mock_serializer(model: account, attributes: attributes)
    assoc_name    = c_sym_plural(user)
    args          = {
      class_name:  user.name,
      foreign_key: c_foreign_key(account),
      through:     c_sym_plural(account_users),
      source:      c_sym(user),
    }
    targs = {
      class_name:  account_users.name,
      foreign_key: c_foreign_key(account),
    }
    sz_args = {
      root: c_path_plural(user),
      key:  c_path_ids(user),
    }
    mock.expect    :has_many, nil, [c_sym_plural(account_users), nil, targs]
    mock.expect    :has_many, nil, [assoc_name, nil, args]
    sz_mock.expect :has_many, nil, [assoc_name, sz_args]
    set_mock_model_associations(mock, sz_mock, fn: fn, dir: 'value')
  end

end
