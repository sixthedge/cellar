$:.push ENV['TOTEM_TEST_HELPER']  # add totem's test_helper.rb to the load path before requiring it

require 'test_helper'
require 'pp'

module Test
  module SerializerOptions
  end
end

def so_error; Totem::Core::Controllers::TotemActionSerializerOptions::ClassMethods::OptionsError; end

class Test::SerializerOptions::Base
  def self.new_so(options)
    send :totem_action_serializer_options, options
    self.new
  end
  def self.before_action(options, &blk)
    invalid_keys = options.keys - [:only, :except, :if, :unless]
    raise "Before filter has invalid keys #{invalid_keys.inspect}"  unless invalid_keys.blank? || blk.blank?
  end
  attr_accessor :action_name
  attr_accessor :serializer_options
  attr_accessor :params
  attr_accessor :current_ability
  attr_accessor :current_user
  attr_accessor :totem_serializer_options
  def tso; totem_serializer_options; end
  def tso_method(method); tso.send(method); end
end

Test::SerializerOptions::Base.class_eval do
  include ::Totem::Core::Controllers::TotemActionSerializerOptions
end

class Test::SerializerOptions::UsersController < Test::SerializerOptions::Base; end
class Test::SerializerOptions::ArgsController  < Test::SerializerOptions::Base; end

module Test::SerializerOptions::Users
  def module_name; :users; end
  def index; end
  def users_index; end
end

module Test::SerializerOptions::AnotherOne
  def module_name; :another_one; end
  def index; end
  def another_one_index; end
end

module Test::SerializerOptions::AnotherTwo
  def module_name; :another_two; end
  def index; end
  def another_two_index; end
end

module Test::SerializerOptions::Args
  def module_name; :args; end
  def zero_args; end
  def one_args(one); end
  def two_args(one, two)
    expect = [:record, :records, :params, :serializer_options, :current_ability, :current_user, :totem_serializer_options, :controller].sort
    unless two.kind_of?(Hash)
      raise "Second arguement should be a hash not #{two.class.name.inspect}"
    end
    if expect != two.keys.sort
      raise "Expect arguments: #{expect.inspect}\nGot arguments: #{two.keys.sort}"
    end
  end
  def three_args(one, two, three); end
end

def so
  {serializer_options: true}
end

def get_controller(options, klass=Test::SerializerOptions::UsersController)
  except_keys                   = [:action_name]
  controller                    = klass.new_so(options.except(*except_keys))
  controller.action_name        = (options[:action_name] || :index).to_s
  controller.params             = {}
  controller.serializer_options = {}
  controller.current_ability    = {}
  controller.current_user       = {}
  controller
end

def get_serializer_options_methods(options)
  get_controller(options).tso_method :serializer_options_methods
end
