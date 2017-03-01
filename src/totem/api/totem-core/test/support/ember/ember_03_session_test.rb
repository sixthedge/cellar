require File.expand_path('../ember_helper', __FILE__)

# Session is the merge of the framework and platform session values.

describe '03: ember.rb session' do

  before do
    before_ember_common(file_ext: '03_inherit*')
  end

  it '03: should be valid' do 
    assert_kind_of Hash, @session
    refute_empty @session, 'Ember session should be populated.'
  end

  it '03: inherit from framework' do
    expect = {
      timeout_time:            1800,
      timeout_warning_time:    120,
      timeout_warning_message: 'framework warning message',
    }
    assert_equal expect, @session
  end

  if debug_on
    it '03: debug' do
      puts "\n"
      pp '03: Ember session config:', @session
    end
  end

end

describe '03a: ember.rb session override all' do

  before do
    before_ember_common(file_ext: '03a_override*')
  end

  it '03a: should be valid' do 
    assert_kind_of Hash, @session
    refute_empty @session, 'Ember session should be populated.'
  end

  it '03a: platform override' do
    expect = {
      timeout_time:            600,
      timeout_warning_time:    300,
      timeout_warning_message: 'platform warning message',
    }
    assert_equal expect, @session
  end

end

describe '03b: ember.rb session override some' do

  before do
    before_ember_common(file_ext: '03b_override*')
  end

  it '03b: should be valid' do 
    assert_kind_of Hash, @session
    refute_empty @session, 'Ember session should be populated.'
  end

  it '03b: platform override' do
    expect = {
      timeout_time:            1800,
      timeout_warning_time:    300,
      timeout_warning_message: 'platform warning message',
    }
    assert_equal expect, @session
  end

end
