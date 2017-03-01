module Thinkspace
  module Common
    class Timetable < ActiveRecord::Base
      totem_associations

      # ###
      # ### Scopes.
      # ###

      def self.scope_by_timeable_ownerables(timeable, ownerables); self.where(timeable: timeable, ownerable: ownerables); end
      def self.scope_not_unlocked; where('unlocked_at IS NULL'); end
      def self.scope_unlock_at_before(time); where('unlock_at <= ?', time); end
      def self.scope_by_phase; where(timeable_type: Thinkspace::Casespace::Phase.name); end
      def self.scope_no_ownerable; where('ownerable_type IS NULL AND ownerable_id IS NULL'); end
      def self.scope_by_teams; where(ownerable_type: Thinkspace::Team::Team.name); end
      def self.scope_by_users; where(ownerable_type: Thinkspace::Common::User.name); end

      # ###
      # ### Helpers
      # ###

      def set_unlocked_at
        self.unlocked_at = Time.now
        self.save
      end

      # ###
      # ### Find/Create.
      # ###

      def self.find_or_create_timetable(timeable, options={})
        raise FindOrCreateError, "Timeable is blank." if timeable.blank?
        ownerable = options[:ownerable]
        tt        = ownerable.blank? ? find_by_timeable(timeable) : find_by_timeable_ownerable(timeable, ownerable)
        if tt.blank?
          user              = options[:user]
          release_at        = options[:release_at]
          due_at            = options[:due_at]
          hash              = {timeable: timeable}
          hash[:ownerable]  = ownerable  if ownerable.present?
          hash[:user_id]    = user.id    if user.present?
          hash[:release_at] = release_at if release_at.present?
          hash[:due_at]     = due_at     if due_at.present?
          tt = self.create(hash)
          raise FindOrCreateError, "Could not find or create timetable for timeable [errors: #{tt.errors.messages}] [ownerable: #{ownerable.inspect}]."  if tt.errors.present?
        end
        raise FindOrCreateError, "Could not find or create timetable state for timeable [ownerable: #{ownerable.inspect}]."  unless tt.present?
        tt
      end

      def self.find_by_timeable(timeable); self.find_by(timeable: timeable); end

      def self.find_by_timeable_ownerable(timeable, ownerable); self.find_by(timeable: timeable, ownerable: ownerable); end

      class FindOrCreateError < StandardError; end

      # # ###
      # # ### Timetable Scope Class.
      # # ###

      # Encapsulate the timetable scope generation in a class.
      # Multiple (or none) association classes can be added to the scope.
      #
      # Generates the appropriate left outer joins (with table aliases) and coalesces values on
      # ownerable(s) (if present) then without an ownerable (e.g. IS NULL).
      # 
      # Ownerables are coalesced in same order as passed.
      # A left outer join is added for each ownerable and IS NULL.
      # e.g. base_class-ownerable1, base_class-ownerable2, base_class, association_classes[0]-ownerable, association_classes[0], ...
      #
      # Usage:
      #   Create a new instance of this class with following arguments:
      #     base_class:          [required] [class] model class of the records returned via the scope
      #     ownerables:          [required] [single ownerable record | array of ownerable records | nil]
      #     association_classes: [optional] [class | hash | string] additional association model classes
      #                          * a class must be a 'belongs_to' association class (e.g. the base class table has a foreign key for the association)
      #                          * the timetable 'timeables' are coalesced in the same order as the classes
      #                          * a string class name can be in module or slash format (e.g. 'Thinkspace::Casespace::Assignment' or 'thinkspace/casespace/assignment')
      #                          * see 'Association class hash keys' below for hash layout
      #   e.g. for a phase: tts = Thinkspace::Common::Timetable::Scope.new(self, ownerable, Thinkspace::Casespace::Assignment)
      #
      # Association class hash keys (use to go up a 'belongs to' association hierarchy):
      #   on:  [required] [class | string] base class belongs_to association class (adds a base class inner join to the association class table)
      #   for: [required] [class | string] association class belongs_to association class
      #   e.g. to include space timetables with a phase:
      #     tts = Thinkspace::Common::Timetable::Scope.new(
      #             self,
      #             ownerable,
      #             'Thinkspace::Casespace::Assignment',
      #             {on: 'Thinkspace::Casespace::Assignment', for: 'Thinkspace::Common::Space'}
      #          )
      #     SQL includes the following from the hash (with tt2 included in coalesce statements):
      #       INNER JOIN "thinkspace_casespace_assignments" ON "thinkspace_casespace_assignments"."id" = "thinkspace_casespace_phases"."assignment_id"
      #       LEFT OUTER JOIN thinkspace_common_timetables tt2
      #         ON thinkspace_casespace_assignments.space_id = tt2.timeable_id AND tt2.timeable_type = 'Thinkspace::Common::Space' ...
      #
      # Additional model based scopes (e.g. other than the timetable scope) can be chained to the timetable scope.
      # Call 'scope' or 'with_scope' on the timetable scope to chain the model based scopes.
      # e.g. tts.select_virual().where().with_scope.active  #=> active is another scope defined in the model
      #
      # Helpers:
      #   coalesce: returns a COALESCE string for a column
      #   value:    returns a COALESCE value for a single record (record id and column are required)
      #
      # Notes:
      #   1. If a 'select_virtual' is the first method called (e.g. a coalesced column), the select "base_class.table_name.*" is suppressed.
      #   2. A 'select_virtual' prefixes the column name with 'v_' e.g. select_virtual(:due_at) #=> coalesce(...) AS v_due_at.
      #   3. If add model scopes to the timetable scope, recommend passing the timetable scope to ensure the table aliases are correct.
      #   4. When association classes are 'strings', the table name is derived from the string (e.g. not constantized first).
      #   5. When association classes are 'classes', the table name is 'klass.table_name' (must use if klass.name does not match the table name).

      class Scope
        attr_reader :base_class, :ownerables, :association_classes
        attr_reader :left_outer_joins, :inner_joins
        attr_reader :table_name

        def initialize(base_class, ownerables, *association_classes)
          @base_class          = base_class
          @ownerables          = ownerables.blank? ? nil : Array.wrap(ownerables)
          @association_classes = association_classes
          @select_virtual      = false
          @left_outer_joins    = Array.new
          @inner_joins         = Array.new
          @table_name          = :thinkspace_common_timetables
        end

        def scope; @current_scope ||= generate_base_scope; end
        alias :with_scope :scope

        def time_now; @time_now ||= Time.now; end

        # ###
        # ### Chainable Scopes.
        # ###

        def select_virtual(col, vname=nil)
          @select_virtual = true
          vname           = "v_#{col}"  if vname.blank?
          @current_scope  = scope.select "#{coalesce(col)} AS #{vname}"
          self
        end

        def where(col, op, val)
          @current_scope = scope.where val.is_a?(Array) ? ["#{coalesce(col)} #{op} IN (?)", val] : ["#{coalesce(col)} #{op} ?", val]
          self
        end

        def where_time(col, op, time=time_now); where(col, op, time); end
        def where_now(op, col); where_time(col, op); end

        def joins(tn)
          @current_scope = scope.joins(tn)
          self
        end

        # ###
        # ### Scope Helpers.
        # ###

        def coalesce(col)
          tc = Array.new
          left_outer_joins.length.times {|i| tc.push("#{table_alias(i)}.#{col}")}
          "COALESCE(#{tc.join(', ')})"
        end

        def value(id, *cols); get_record_values(id, cols); end
        alias :values :value

        private

        # ###
        # ### Base Scope.
        # ###

        def generate_base_scope
          base = @select_virtual.blank? ? base_class.select("#{base_class.table_name}.*") : base_class
          generate_left_outer_joins
          inner_joins.each      {|tn|  base = base.joins(tn)}
          left_outer_joins.each {|loj| base = base.joins(loj)}
          base
        end

        # ###
        # ### Left Outer Joins.
        # ###

        def generate_left_outer_joins
          join_tables(base_class, :id)
          association_classes.each {|klass| join_tables(klass)}
        end

        def join_tables(klass, fk=nil)
          if ownerables.blank?
            join_no_ownerables(klass, fk)
          else
            join_with_ownerables(klass, fk)
            join_no_ownerables(klass, fk)
          end
        end

        def join_no_ownerables(klass, fk); make_join(klass, fk); end

        def join_with_ownerables(klass, fk)
          ownerables.each do |ownerable|
            next if ownerable.blank?
            make_join(klass, fk, ownerable)
          end
        end

        def make_join(klass, fk, ownerable=nil)
          klass.is_a?(Hash) ? make_join_from_hash(klass, fk, ownerable) : make_join_from_class(klass, fk, ownerable)
        end

        def make_join_from_class(klass, fk, ownerable=nil)
          fk   = foreign_key(klass) if fk.blank?
          ta   = next_table_alias
          type = class_type(klass)
          join = "LEFT OUTER JOIN #{table_name} #{ta}"
          join += " ON #{base_class.table_name}.#{fk} = #{ta}.timeable_id"
          join += " AND #{ta}.timeable_type = '#{type}'"
          add_to_left_outer_joins_with_ownerable(join, ta, ownerable)
        end

        def make_join_from_hash(hash, fk, ownerable=nil)
          klass = hash[:on]
          inner_joins.push inner_join_table_name(klass)
          for_klass = hash[:for]
          fk        = foreign_key(for_klass)  if fk.blank?
          ta        = next_table_alias
          tn        = class_table_name(klass)
          type      = class_type(for_klass)
          join      = "LEFT OUTER JOIN #{table_name} #{ta}"
          join     += " ON #{tn}.#{fk} = #{ta}.timeable_id"
          join     += " AND #{ta}.timeable_type = '#{type}'"
          add_to_left_outer_joins_with_ownerable(join, ta, ownerable)
        end

        def add_to_left_outer_joins_with_ownerable(join, ta, ownerable=nil)
          if ownerable.blank?
            join += " AND #{ta}.ownerable_id IS NULL"
          else
            join += " AND #{ta}.ownerable_id = #{ownerable.id}"
            join += " AND #{ta}.ownerable_type = '#{ownerable.class.name}'"
          end
          left_outer_joins.push(join)
        end

        def class_table_name(klass);      klass.is_a?(String) ? klass.tableize.gsub('/','_') : klass.table_name; end
        def inner_join_table_name(klass); class_table_name(klass).singularize.to_sym; end
        def foreign_key(klass);           class_type(klass).foreign_key; end
        def class_type(klass);            klass.is_a?(String) ? klass.classify : klass.name; end

        def table_alias(count); "tt#{count}"; end
        def next_table_alias;   table_alias(left_outer_joins.length); end

        # ###
        # ### Single Record Helpers.
        # ###

        def virtual_column(col); "_#{col}_"; end

        def virtual_select(col); @current_scope = scope.select "#{coalesce(col)} AS #{virtual_column(col)}"; end

        def get_record_values(id, cols)
          return nil if id.blank? || cols.blank?
          cols.each {|col| virtual_select(col)}
          record = scope.where(id: id).first
          return nil if record.blank?
          if cols.length == 1
            record.send virtual_column(cols.first)
          else
            hash = HashWithIndifferentAccess.new
            cols.each do |col|
              hash[col] = record.send virtual_column(col)
            end
            hash
          end
        end

      end

    end
  end
end
