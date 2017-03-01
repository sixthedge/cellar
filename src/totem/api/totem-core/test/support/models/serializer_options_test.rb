require File.expand_path('../models_helper', __FILE__)

# Caution: Make sure models paths are unique in each 'it' test. Othwerwise will bleed between tests.
#          Using: model-name_filename-num (plus _model-name-unique-num-when-needed)

def so_user;     @_so_user     ||= path_to_class('test/platform/sz/so_user'); end
def so_user_sz;  @_so_user_sz  ||= class_serializer(so_user).new({}); end
def so_space;    @_so_space    ||= path_to_class('test/platform/sz/so_space'); end
def so_space_sz; @_so_space_sz ||= class_serializer(so_space).new({}); end

describe 'totem core serializer concerns options.rb' do

  before do
    set_environment
    load_platform_configs(file: __FILE__, file_ext: '01_*')
    register_framework_and_platform
    @so = @env.class.test_framework.serializer_options.new
  end

  it 'include association scope global' do
    assoc = c_sym_plural(so_space)
    @so.include_association(assoc)
    assert_equal true, @so.include_association?(so_user_sz, assoc)
  end

  it 'include association scope root' do
    @so.set_root_serializer(so_user_sz)
    assoc = c_sym_plural(so_space)
    @so.include_association(assoc, scope: :root)
    assert_equal true, @so.include_association?(so_user_sz, assoc)
  end

  it 'include association scope association' do
    assoc = c_sym_plural(so_space)
    @so.include_association(assoc, scope: c_sym(so_user))
    assert_equal true, @so.include_association?(so_user_sz, assoc)
  end

  it 'blank association scope global' do
    assoc = c_sym_plural(so_space)
    @so.blank_association(assoc)
    assert_equal true, @so.blank_association?(so_user_sz, assoc)
  end

  it 'blank association scope root' do
    @so.set_root_serializer(so_user_sz)
    assoc = c_sym_plural(so_space)
    @so.blank_association(assoc, scope: :root)
    assert_equal true, @so.blank_association?(so_user_sz, assoc)
  end

  it 'blank association scope association' do
    assoc = c_sym_plural(so_space)
    @so.blank_association(assoc, scope: c_sym(so_user))
    assert_equal true, @so.blank_association?(so_user_sz, assoc)
  end

  it 'remove association scope global' do
    assoc = c_sym_plural(so_space)
    @so.remove_association(assoc)
    assert_equal true, @so.remove_association?(so_user_sz, assoc)
  end

  it 'remove association scope root' do
    @so.set_root_serializer(so_user_sz)
    assoc = c_sym_plural(so_space)
    @so.remove_association(assoc, scope: :root)
    assert_equal true, @so.remove_association?(so_user_sz, assoc)
  end

  it 'remove association scope association' do
    assoc = c_sym_plural(so_space)
    @so.remove_association(assoc, scope: c_sym(so_user))
    assert_equal true, @so.remove_association?(so_user_sz, assoc)
  end

  it 'scope association scope global' do
    assoc = c_sym_plural(so_space)
    scope = {where: 'id > 1', order: :id}
    @so.scope_association(assoc, scope)
    assert_equal scope, @so.get_association_scope(so_user_sz, assoc).symbolize_keys
  end

  it 'scope association scope root' do
    @so.set_root_serializer(so_user_sz)
    assoc = c_sym_plural(so_space)
    scope = {where: 'id > 1', order: :id}
    @so.scope_association(assoc, scope.merge(scope: :root))
    assert_equal scope, @so.get_association_scope(so_user_sz, assoc).symbolize_keys
  end

  it 'scope association scope association' do
    assoc = c_sym_plural(so_space)
    scope = {where: 'id > 1', order: :id}
    @so.scope_association(assoc, scope.merge(scope: c_sym(so_user)))
    assert_equal scope, @so.get_association_scope(so_user_sz, assoc).symbolize_keys
  end

  it 'authorize action scope global' do
    assoc       = c_sym_plural(so_space)
    auth_action = :update
    @so.authorize_action(auth_action, assoc)
    assert_equal auth_action, @so.get_authorize_action(so_user_sz, assoc)
  end

  it 'authorize action scope root' do
    @so.set_root_serializer(so_user_sz)
    assoc       = c_sym_plural(so_space)
    auth_action = :update
    @so.authorize_action(auth_action, assoc, scope: :root)
    assert_equal auth_action, @so.get_authorize_action(so_user_sz, assoc)
  end

  it 'authorize action scope association' do
    assoc       = c_sym_plural(so_space)
    auth_action = :update
    @so.authorize_action(auth_action, assoc, scope: c_sym(so_user))
    assert_equal auth_action, @so.get_authorize_action(so_user_sz, assoc)
  end

  it 'authorize action default' do
    assoc       = c_sym_plural(so_space)
    assert_equal :read, @so.get_authorize_action(so_user_sz, assoc)
  end

end
