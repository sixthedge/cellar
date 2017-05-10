totem_test_helper = ENV['TOTEM_TEST_HELPER']
$:.push(totem_test_helper)  unless $:.include?(totem_test_helper) # add totem's test_helper.rb to the load path before requiring it

require 'test_helper'
require 'pp'

PaperTrail.enabled = false

module Test; end

def path_to_module(path)
  path_mod_name = path.to_s.camelize
  path_mod      = path_mod_name.safe_constantize
  return path_mod  if path_mod.present? && path_mod.kind_of?(Module)
  raise "Path #{path.inspect} constant already exists as a #{path_mod.name} and is not a module."  if path_mod.present?
  parent_mod_name = path_mod_name.deconstantize
  parent_mod      = parent_mod_name.safe_constantize
  path_to_module(parent_mod_name.underscore)  if parent_mod.blank?  # recursive call for nesting modules
  parent_mod      = parent_mod_name.safe_constantize
  raise "Path #{path.inspect} parent #{parent_mod.inspect} does not exist.  Is it defined?"  if parent_mod.blank?
  mod_name = path_mod_name.demodulize
  mod      = parent_mod.const_set(mod_name, Module.new)
  raise "Could not create module #{mod_name.inspect} in module #{parent_mod.inspect}."  if mod.blank?
  mod
end

def require_test_helper_files(dir)
  path_to_module("test/#{dir.to_s.gsub('../','')}")
  helper_files = Dir.glob(File.expand_path("../#{dir}/**/*.rb", __FILE__))
  helper_files.each do |file|
     require file
  end
end

module Test; module Casespace
  require_test_helper_files(:casespace)
  module All
    extend ActiveSupport::Concern
    included do
      # Convience module to include 'all' casespace helpers.
      # Note: Seed helper is not included as it is a class.
      include Ability
      include Assert
      include Controllers
      include Debug
      include Json
      include Models
      include Routes
      include RouteModels
      include Serialize
      include TerminalColors
      include Utility
    end # included
  end
end; end
