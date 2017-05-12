module Test::Ability::Rules
  extend ActiveSupport::Concern
  included do

    def get_ability_rules(username); get_ability(username).send(:rules); end

    def get_ability_actions(username)
      hash = map_ability_model_rules(username)
      names = hash.keys.sort
      names.each do |name|
        hash[name] = hash[name].keys.sort
      end
      hash
    end

    def get_ability_rules_for_class(username, klass); get_ability_rules(username).select {|r| r.subjects.include?(klass)}; end

    def print_ability_rules(username)
      user       = get_user(username)
      messages   = Array.new
      rules_hash = map_ability_model_rules(username, messages)
      puts "\n"
      puts color_line "--Ability rules for #{user.first_name.inspect}".ljust(80,'-'), :cyan, :bold
      rules_hash.keys.sort.each do |name|
        hash = rules_hash[name]
        puts "\n"
        puts color_line "  #{name}", :green
        actions = hash.keys.sort
        actions.each do |action|
          condition = hash[action]
          puts "    #{action.to_s.ljust(20,'.')}#{condition}"
        end
      end
      print_ability_rule_messages(messages, '--Ability rule messages:')
    end

    def compare_ability_rules(username1, username2)
      messages = Array.new
      user1    = get_user(username1)
      user2    = get_user(username2)
      name1    = user1.first_name
      name2    = user2.first_name
      h1       = map_ability_model_rules(user1, messages)
      h2       = map_ability_model_rules(user2, messages)
      nl       = [name1.length, name2.length].max + 2
      names    = h1.keys + h2.keys
      puts "\n"
      puts "--Compare ability rules for #{name1.inspect} and #{name2.inspect}".ljust(80,'-')
      names.uniq.sort.each do |name|
        name_header = false
        case
        when h1.has_key?(name)  && h2.has_key?(name)
          a1 = h1[name].keys.sort
          a2 = h2[name].keys.sort
          if a1 == a2
            a1.each do |a|
              c1 = h1[name][a]
              c2 = h2[name][a]
              unless c1 == c2
                puts "\n"
                puts "#{name}"  unless name_header
                name_header = true
                puts "  -- conditions differ:"
                puts "      ##{a}"
                puts "          #{name1.ljust(nl,'.')}#{c1}"
                puts "          #{name2.ljust(nl,'.')}#{c2}"
              end
            end
          else
            puts "\n"
            puts "#{name}"  unless name_header
            name_header = true
            puts "  -- actions differ:"
            puts "     #{name1.ljust(nl,'.')}#{a1}"
            puts "     #{name2.ljust(nl,'.')}#{a2}"
            a1diff = a1 - a2
            a2diff = a2 - a1
            puts "     #{name1.ljust(nl,'+')}#{a1diff}"  if a1diff.present?
            puts "     #{name2.ljust(nl,'+')}#{a2diff}"  if a2diff.present?
          end
        when h1.has_key?(name)  && !h2.has_key?(name)
          messages.push "Only #{user1.first_name.inspect} has ability for #{name.inspect}"
        when !h1.has_key?(name) && h2.has_key?(name)
          messages.push "Only #{user2.first_name.inspect} has ability for #{name.inspect}"
        else
        end
      end
      print_ability_rule_messages(messages, '--Compare ability messages:')
    end

    def print_cancan_rules(model_class, *args)
      return if args.blank?
      get_ability(args.first)  # load the ability class with debug messages so not in print
      puts "\n"
      puts "--#{model_class.name.inspect} ability rules".ljust(80,'-')
      args.each do |username|
        user  = get_user(username)
        puts "\n"
        puts "--cancan rules for #{user.first_name.inspect}:".ljust(40,'-')
        puts "\n"
        pp get_ability_rules_for_class(user, model_class)
      end
    end

    def print_ability_rule_messages(messages, title='')
      return if messages.blank?
      puts "\n"
      puts "--#{title}:"
      messages.each_with_index do |msg, index|
        puts "#{(index+1).to_s.rjust(4)}. #{msg}"
      end
    end

    def map_ability_model_rules(username, messages=[])
      user  = get_user(username)
      rules = get_ability_rules(user)
      map_ability_rules(user, rules, messages)
    end

    def map_ability_rules(user, rules, messages=[])
      hash = Hash.new
      rules.each do |rule|
        rule.subjects.each do |subject|
          name      = subject.name
          name_hash = hash[name]
          name_hash = hash[name] = Hash.new  if name_hash.blank?
          rule.actions.each do |action|
            if name_hash.has_key?(action)
              messages.push "Duplicate action #{action.inspect} for class #{name.inspect} user #{user.first_name.inspect}"
            end
            name_hash[action] = rule.conditions
          end
        end
      end
      hash
    end

  end # included
end
