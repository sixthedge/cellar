$:.push ENV['TOTEM_TEST_HELPER']  # add totem's test_helper.rb to the load path before requiring it

require 'test_helper'
require 'pp'

module Test
  module ActionAuthorize
  end
end

def rt_error; RuntimeError; end

class Test::ActionAuthorize::ControllerBase
  cattr_accessor :before_action_block
  def self.new_aa(options)
    send :totem_action_authorize!, options
    self.new
  end
  def self.before_action(options, &blk)
    self.before_action_block = blk
    invalid_keys = options.keys - [:only, :except, :if, :unless]
    raise "Before filter has invalid keys #{invalid_keys.inspect}"  unless invalid_keys.blank? || blk.blank?
  end
  attr_accessor :params
  attr_accessor :action_name
  def run_before_action(controller)
    before_action_block.call(controller)
  end
end

Test::ActionAuthorize::ControllerBase.class_eval do
  include ::Totem::Core::Controllers::TotemActionAuthorize
end

module Test::ActionAuthorize::AuthorizeUsers
  def totem_action_authorize_record_from_params!; raise "totem_action_authorize_record_from_params! method called"; end
  def totem_action_authorize_ownerable_record_from_params!; raise "totem_action_authorize_ownerable_record_from_params! method called"; end
  def totem_action_authorize_view_type_from_params!; raise "totem_action_authorize_view_type_from_params! method called"; end
  def totem_action_authorize_verify_record_ownerable!(controller, polymorphic); raise "totem_action_authorize_verify_record_ownerable! method called with polymorphic #{polymorphic.inspect}"; end
  def action_authorize!; raise "action_authorize! method called"; end
end

class Test::ActionAuthorize::UsersController < Test::ActionAuthorize::ControllerBase
  include Test::ActionAuthorize::AuthorizeUsers
end

class Test::ActionAuthorize::NoOverridesController < Test::ActionAuthorize::ControllerBase
end

def get_aa_controller(options, klass=Test::ActionAuthorize::UsersController)
  except_keys = []
  c = klass.new_aa(options.except(*except_keys))
  c.action_name = options[:action_name]
  c
end

def get_no_overrides_aa_controller(options)
  get_aa_controller(options, Test::ActionAuthorize::NoOverridesController)
end
