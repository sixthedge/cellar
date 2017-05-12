require 'ability_helper'
Test::Casespace::Seed.load(config: :ability)
module Test; module AbilityModVsClass; class PrintActions < ActiveSupport::TestCase

  # ### MUST ADD 'TEST' TO THE MODULE NAME IN THE MODS DIRECTORY FILES!
  # e.g. rename: 'module Thinkspace' to 'module TestThinkspace'
  # Un-comment the 'it' tests wanted.

  def self.mod_files; Dir.glob(File.expand_path("../mods/**/*.rb", __FILE__)); end

  mod_files.each do |file|
    require file
  end

  def self.get_mod_ability(user)
    klass = ModAbility
    mod_files.each do |file|
      basename = File.basename(file, '.rb')
      mod_name = "TestThinkspace::Authorization::#{basename.camelize}"
      mod      = mod_name.safe_constantize
      klass.send(:include, mod)
    end
    klass.new(user)
  end

  class ModAbility
    include ::CanCan::Ability
    attr_reader :user
    def initialize(muser=nil)
      @user = muser
      thinkspace_casespace_ability
      thinkspace_weather_forecaster_ability  if self.respond_to?(:thinkspace_weather_forecaster_ability)
    end
    private
    def set_user_role(role); end
    def set_crud_alias_actions; alias_action :read, :create, :update, :destroy, to: :crud; end
    def set_read_alias_actions; alias_action :index, :show, :select, :view, to: :read; end
  end

  include Casespace::TerminalColors
  include Casespace::Ability
  include Casespace::Models
  include Casespace::Utility
  include Ability::Rules

  def print_class_vs_mod(user)
    class_hash = map_ability_model_rules(user)
    mod_rules  = self.class.get_mod_ability(user).send(:rules)
    mod_hash   = map_ability_rules(user, mod_rules)
    messages   = Array.new
    messages  += print_class_vs_mod_classes(class_hash, mod_hash)
    messages  += print_class_vs_mod_actions(class_hash, mod_hash)
    puts "\n"
    if messages.blank?
      puts color_line("User: #{user.first_name}", :cyan, :bold) + color_line(" abilities are the same!", :green)
    else
      puts color_line("User: #{user.first_name}", :cyan, :bold)
      puts messages.join("\n")
    end
  end

  def print_class_vs_mod_classes(class_hash, mod_hash)
    messages = Array.new
    ckeys    = class_hash.keys.sort
    mkeys    = mod_hash.keys.sort
    cdiff    = ckeys - mkeys
    mdiff    = mkeys - ckeys
    if cdiff.present?
      messages.push color_line("  Class classes not in mod classes=", :red) + "#{cdiff}"
    end
    if mdiff.present?
      messages.push color_line("  Mod classes not in class classes=", :red) + "#{mdiff}"
    end
    messages
  end

  def print_class_vs_mod_actions(class_hash, mod_hash)
    all_messages = Array.new
    class_hash.keys.sort.each do |key|
      cactions = class_hash[key]
      mactions = mod_hash[key]
      messages = Array.new
      case
      when cactions.present? && mactions.present?
        ca    = cactions.keys.sort
        ma    = mactions.keys.sort
        cdiff = ca - ma
        mdiff = ma - ca
        dm    = color_line('mod'.ljust(5), :yellow)
        dc    = color_line('class'.ljust(5), :yellow)
        messages.push color_line("    Missing actions #{dm} = #{cdiff}", :red) if cdiff.present?
        messages.push color_line("    Missing actions #{dc} = #{mdiff}", :red) if mdiff.present?
      when cactions.present?
      when mactions.present?
      else
      end
      if messages.present?
        all_messages.push "  #{key}"
        all_messages += messages
      end
    end
    all_messages
  end

  describe 'ability'  do
    let (:owner)    {get_user(:owner_1)}
    let (:updater)  {get_user(:update_1)}
    let (:reader)   {get_user(:read_1)}

    describe 'rules' do
      it "print class vs mod reader" do
        # print_class_vs_mod(reader)
      end
      it "print class vs mod updater" do
        # print_class_vs_mod(updater)
      end
    end

  end

end; end; end
