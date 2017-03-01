require File.expand_path('../models_helper', __FILE__)

# Caution: Make sure models paths are unique in each 'it' test. Othwerwise will bleed between tests.
#          Using: model-name_filename-num (plus _model-name-unique-num-when-needed)
# Tests have been set up in the order (do not have to be in this order):
#   fn, create model classes, attributes, mocks, assoc name, args, expects, add associations

describe 'associations.rb belongs_to with mock serializer' do

  before do
    set_environment
    set_base_framework_serializer_class
  end

  it 'engine association paths should have valid test engines' do
    basic_association_paths_test
  end

  it '30: user.profile and profile.user' do
    fn      = '30'
    user    = path_to_class("test/associations/one/user_#{fn}")
    profile = path_to_class("test/associations/one/profile_#{fn}")
    # user.profile
    attributes = [:id, :name]
    mock       = mock_model(model: user, attributes: attributes)
    sz_mock    = mock_serializer(model: user, attributes: attributes)
    assoc_name = c_sym(profile)
    args       = {
      class_name:   profile.name,
      foreign_key:  c_foreign_key(profile),
    }
    sz_args = {
      root: c_path_plural(profile),
      key:  c_path_id(profile),
    }
    mock.expect    :belongs_to, nil, [assoc_name, nil, args]
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

  it '31: cross-path user.profile and profile.user' do
    fn      = '31'
    user    = path_to_class("test/associations/one/user_#{fn}")
    profile = path_to_class("test/associations/two/profile_#{fn}")
    # user.profile
    attributes = [:id, :name]
    mock       = mock_model(model: user, attributes: attributes)
    sz_mock    = mock_serializer(model: user, attributes: attributes)
    assoc_name = c_sym(profile)
    args       = {
      class_name:   profile.name,
      foreign_key:  c_foreign_key(profile),
    }
    sz_args = {
      root: c_path_plural(profile),
      key:  c_path_id(profile),
    }
    mock.expect    :belongs_to, nil, [assoc_name, nil, args]
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

  it '32: polymorphic' do
    fn         = '32'
    user       = path_to_class("test/associations/one/user_#{fn}")
    attributes = [:id, :name, :email]
    mock       = mock_model(model: user, attributes: attributes)
    sz_mock    = mock_serializer(model: user, attributes: attributes)
    assoc_name = :polymorphicable
    args       = {
      polymorphic: true,
    }
    sz_args = {
      polymorphic: true,
    }
    mock.expect    :belongs_to, nil, [assoc_name, nil, args]
    sz_mock.expect :has_one, nil, [assoc_name, sz_args]
    set_mock_model_associations(mock, sz_mock, fn: fn, dir: 'value')
  end

  it '33: self alias' do
    fn         = '33'
    user       = path_to_class("test/associations/one/user_#{fn}")
    attributes = [:id, :name, :email]
    mock       = mock_model(model: user, attributes: attributes)
    sz_mock    = mock_serializer(model: user, attributes: attributes)
    assoc_name = :test_associations_one_owner
    args       = {
      foreign_key: 'owner_id',
      class_name:  user.name,
    }
    sz_args = {
      root: 'test/associations/one/user33s',
      key:  'test/associations/one/owner_id',
    }
    mock.expect    :belongs_to, nil, [assoc_name, nil, args]
    sz_mock.expect :has_one, nil, [assoc_name, sz_args]
    set_mock_model_associations(mock, sz_mock, fn: fn, dir: 'value')
  end

  it '34: user.account.readonly' do
    fn         = '34'
    user       = path_to_class("test/associations/one/user_#{fn}")
    account    = path_to_class("test/associations/one/account_#{fn}")
    attributes = [:id, :name, :email]
    mock       = mock_model(model: user, attributes: attributes)
    sz_mock    = mock_serializer(model: user, attributes: attributes)
    assoc_name = c_sym(account)
    args       = {
      class_name:  account.name,
      foreign_key: c_foreign_key(account),
    }
    sz_args = {
      root: c_path_plural(account),
      key:  c_path_id(account),
    }
    expect_model_association_with_scope(mock,
      method:     :belongs_to,
      fn:         fn,
      assoc_name: assoc_name,
      args:       args,
      scopes:     {readonly: nil},
    )
    sz_mock.expect :has_one, nil, [assoc_name, sz_args]
    set_mock_model_associations(mock, sz_mock, fn: fn, dir: 'value')
  end

  it '35: user.account.order(id)' do
    fn      = '35'
    user       = path_to_class("test/associations/one/user_#{fn}")
    account    = path_to_class("test/associations/one/account_#{fn}")
    attributes = [:id, :name, :email]
    mock       = mock_model(model: user, attributes: attributes)
    sz_mock    = mock_serializer(model: user, attributes: attributes)
    assoc_name = c_sym(account)
    args       = {
      class_name:  account.name,
      foreign_key: c_foreign_key(account),
    }
    sz_args = {
      root: c_path_plural(account),
      key:  c_path_id(account),
    }
    expect_model_association_with_scope(mock,
      method:     :belongs_to,
      fn:         fn,
      assoc_name: assoc_name,
      args:       args,
      scopes:     {order: 'id'},
    )
    sz_mock.expect :has_one, nil, [assoc_name, sz_args]
    set_mock_model_associations(mock, sz_mock, fn: fn, dir: 'value')
  end

  # Psych::SyntaxError if use the alternative hash syntax: where(active: true).
  it '36: user.account.where(:active => true).order(:id).readonly' do
    fn      = '36'
    user    = path_to_class("test/associations/one/user_#{fn}")
    account = path_to_class("test/associations/one/account_#{fn}")
    attributes = [:id, :name, :email]
    mock       = mock_model(model: user, attributes: attributes)
    sz_mock    = mock_serializer(model: user, attributes: attributes)
    assoc_name = c_sym(account)
    args       = {
      class_name:  account.name,
      foreign_key: c_foreign_key(account),
    }
    sz_args = {
      root: c_path_plural(account),
      key:  c_path_id(account),
    }
    expect_model_association_with_scope(mock,
      method:     :belongs_to,
      fn:         fn,
      assoc_name: assoc_name,
      args:       args,
      scopes:     {where: {active: true}, order: :id, readonly: nil},
    )
    sz_mock.expect :has_one, nil, [assoc_name, sz_args]
    set_mock_model_associations(mock, sz_mock, fn: fn, dir: 'value')
  end

  it '37: user.account.order(:id).readonly with accepts nested attributes for' do
    fn      = '37'
    user    = path_to_class("test/associations/one/user_#{fn}")
    account = path_to_class("test/associations/one/account_#{fn}")
    attributes = [:id, :name, :email]
    mock       = mock_model(model: user, attributes: attributes)
    sz_mock    = mock_serializer(model: user, attributes: attributes)
    assoc_name = c_sym(account)
    args       = {
      class_name:  account.name,
      foreign_key: c_foreign_key(account),
    }
    sz_args = {
      root: c_path_plural(account),
      key:  c_path_id(account),
    }
    expect_model_association_with_scope(mock,
      method:     :belongs_to,
      fn:         fn,
      assoc_name: assoc_name,
      args:       args,
      scopes:     {order: :id, readonly: nil},
    )
    mock.expect    :accepts_nested_attributes_for, nil, [c_sym_plural(account), {allow_destroy: true}]
    sz_mock.expect :has_one, nil, [assoc_name, sz_args]
    set_mock_model_associations(mock, sz_mock, fn: fn, dir: 'value')
  end

  it '38: most options - not polymorphic' do
    fn         = '38'
    user       = path_to_class("test/associations/one/user_#{fn}")
    attributes = [:id, :name, :email, :another]
    mock       = mock_model(model: user, attributes: attributes)
    sz_mock    = mock_serializer(model: user, attributes: attributes)
    assoc_name = :test_associations_one_some_alias
    args       = {
      class_name:   'Test::Associations::One::User38',
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
      method:     :belongs_to,
      fn:         fn,
      assoc_name: assoc_name,
      args:       args,
      scopes:     {order: 'name', readonly: nil},
    )
    mock.expect    :accepts_nested_attributes_for, nil, [c_sym_plural(user), {key: 'value'}]
    sz_mock.expect :has_one, nil, [assoc_name, sz_args]
    set_mock_model_associations(mock, sz_mock, fn: fn, dir: 'value')
  end

  it '39: most options - polymorphic' do
    fn         = '39'
    user       = path_to_class("test/associations/one/user_#{fn}")
    attributes = [:id, :name, :email, :another]
    mock       = mock_model(model: user, attributes: attributes)
    sz_mock    = mock_serializer(model: user, attributes: attributes)
    assoc_name = :some_alias
    args       = {
      class_name:   'should_be_used',
      polymorphic:  true,
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
      polymorphic: true,
    }
    expect_model_association_with_scope(mock,
      method:     :belongs_to,
      fn:         fn,
      assoc_name: assoc_name,
      args:       args,
      scopes:     {order: 'name', readonly: nil},
    )
    sz_mock.expect :has_one, nil, [assoc_name, sz_args]
    set_mock_model_associations(mock, sz_mock, fn: fn, dir: 'value')
  end

end
