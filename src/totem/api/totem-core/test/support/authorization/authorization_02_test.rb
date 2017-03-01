require File.expand_path('../authorization_helper', __FILE__)

describe '02: authorization.rb with platform overrides' do

  before do 
    set_environment
    load_platform_configs(file: __FILE__, file_ext: '02_*')
    register_framework_and_platform
    register_engine
    @auth = @env.authorization
  end

  it '02: should be valid' do 
    assert_kind_of Hash, @auth.platforms
    refute_empty @auth.platforms, 'Authorization should be populated.'
  end

  it '02: should have framework' do
    refute_empty @auth.platform('test_framework'), 'Framework test_framework should be populated.'
  end

  it '02: should have platform' do
    refute_empty @auth.platform('test_platform'), 'Platform test_platform should be populated.'
  end

  it '02: authorize by' do
    assert_equal 'overcan', @auth.current_authorize_by(user)
  end

  it '02: ability class' do
    assert_equal framework_ability, @auth.current_ability_class(user)
  end

  it '02: serializer include modules in order' do
    expect = [Test::Framework::Ability, Test::Framework::Authorize, Test::Framework::ActiveModelSerializer]
    assert_equal expect, @auth.current_serializer_include_modules(user)
  end

  it '02: serializer defaults' do
    expect = {authorize_action: 'destroy', ability_actions: ['read', 'update', 'destroy'], another: 'another default'}
    assert_equal expect, @auth.current_serializer_defaults(user)
  end

  if debug_on
    it '02: debug' do
      puts "\n"
      puts "02: Authorization platforms: #{@auth.platforms.inspect}"
    end
  end

end
