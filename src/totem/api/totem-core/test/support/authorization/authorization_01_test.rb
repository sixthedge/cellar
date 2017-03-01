require File.expand_path('../authorization_helper', __FILE__)

describe '01: authorization.rb' do

  before do 
    set_environment
    load_platform_configs(file: __FILE__, file_ext: '01_*')
    register_framework_and_platform
    register_engine
    @auth = @env.authorization
  end

  it '01: should be valid' do 
    assert_kind_of Hash, @auth.platforms
    refute_empty @auth.platforms, 'Authorization should be populated.'
  end

  it '01: should have framework' do
    refute_empty @auth.platform('test_framework'), 'Framework test_framework should be populated.'
  end

  it '01: should have platform' do
    refute_empty @auth.platform('test_platform'), 'Platform test_platform should be populated.'
  end

  it '01: authorize by' do
    assert_equal 'cancan', @auth.current_authorize_by(user)
  end

  it '01: ability class' do
    assert_equal platform_ability, @auth.current_ability_class(user)
  end

  it '01: serializer include modules in order' do
    expect = [Test::Framework::ActiveModelSerializer, Test::Framework::Authorize, Test::Framework::Ability]
    assert_equal expect, @auth.current_serializer_include_modules(user)
  end

  it '01: serializer defaults' do
    expect = {authorize_action: 'update', ability_actions: 'crud'}
    assert_equal expect, @auth.current_serializer_defaults(user)
  end

  if debug_on
    it '01: debug' do
      puts "\n"
      puts "01: Authorization platforms: #{@auth.platforms.inspect}"
    end
  end

end
