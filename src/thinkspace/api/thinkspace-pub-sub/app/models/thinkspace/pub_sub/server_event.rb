module Thinkspace
  module PubSub
    class ServerEvent < ActiveRecord::Base
      totem_associations

      # ###
      # ### Scopes.
      # ###

      def self.scope_by_room(room);    where("rooms ? '#{room}'"); end # when self.rooms contains room
      def self.scope_by_rooms(rooms);  where("rooms ?| #{get_json_query_array(rooms)}"); end # when self.rooms contains any room in the rooms array
      def self.scope_by_ge_time(time); where('created_at >= ?', time); end
      def self.scope_by_le_time(time); where('created_at <= ?', time); end
      def self.scope_by_message_event; where(event: :message); end

      def self.scope_messages(rooms, start_time=nil, end_time=nil)
        scope = active.scope_by_message_event.scope_by_rooms(rooms)
        scope = scope.scope_by_ge_time(start_time) if start_time.present?
        scope = scope.scope_by_le_time(end_time)   if end_time.present?
        scope
      end

      def self.get_json_query_array(array)
        str = Array.wrap(array).map {|a| "'#{a}'"}.join(',')
        "array[#{str}]"
      end

      def self.scope_by_timers; where('timer_settings IS NOT NULL'); end

      def self.scope_by_active_timers; scope_by_timers.where('timer_cancelled_at IS NULL'); end

      def self.scope_timers_by_gt_time(time=Time.now.utc)
        where('timer_end_at > ?', time).scope_by_active_timers
      end

      # ###
      # ### Validations.
      # ###

      validates_presence_of :channel, :origin, :authable, :user_id
      validate :validate_rooms
      validate :validate_value
      validate :validate_records
      validate :validate_timer

      TIMER_SETTINGS_UNIT = ['minute', 'second']
      TIMER_SETTINGS_TYPE = ['countdown', 'countup', 'once']

      def validate_rooms
        return if timer_cancel?
        self.errors.add(:rooms, "Rooms must be an array") unless self.rooms.is_a?(Array)
      end
      def validate_value;   self.errors.add(:value,   "Value must be a hash")   if self.value.present?   && !self.value.is_a?(Hash); end
      def validate_records; self.errors.add(:records, "Records must be a hash") if self.records.present? && !self.records.is_a?(Hash); end
      def validate_timer
        return if timer_cancel?
        return unless timer?
        validate_timer_settings
        validate_timer_times
      end
      def validate_timer_settings
        self.errors.add(:timer_settings, "Timer settings must be a hash")   unless self.timer_settings.is_a?(Hash)
        self.errors.add(:timer_settings, "Timer settings cannot be blank")  if self.timer_settings.blank?
        type = self.timer_settings['type']
        unit = self.timer_settings['unit']
        self.errors.add(:timer_settings, "Timer settings 'type' must be #{TIMER_SETTINGS_TYPE}") unless TIMER_SETTINGS_TYPE.include?(type)
        return if type == 'once'
        self.errors.add(:timer_settings, "Timer settings 'unit' must be #{TIMER_SETTINGS_UNIT}") unless TIMER_SETTINGS_UNIT.include?(unit)
      end
      def validate_timer_times
        self.errors.add(:timer_end_at, "Timer requires a 'timer_end_at'") if self.timer_end_at.blank?
        interval = self.timer_settings['interval']
        unit     = self.timer_settings['unit']
        start_at = self.timer_start_at
        return if interval.blank? && start_at.blank?
        self.errors.add(:timer_settings, "Timer settings requires an 'interval' with 'timer_start_at'") if interval.blank?
        self.errors.add(:timer_settings, "Timer settings requires an 'unit' with 'timer_start_at'")     if unit.blank?
        self.errors.add(:timer_start_at, "Timer requires a 'timer_start_at' with an 'interval'") if self.timer_start_at.blank? && interval.present?
        self.errors.add(:timer_settings, "Timer settings 'interval' must be a number") unless interval.to_s.match(/^\d+$/)
      end

      def timer?; self.timer_end_at.present? || self.timer_start_at.present? || !self.timer_settings.nil?; end
      def timer_cancel?; self.event == 'timer_cancel'; end

      def cancel_timer(time=Time.now.utc)
        self.timer_cancelled_at = time
        raise "Timer server event [id #{self.id}] could not be cancelled." unless self.save
      end

      # ###
      # ### AASM
      # ###

      include AASM
      aasm column: :state do
        state :active, initial: true
        state :inactive
        state :archived
        event :activate do;   transitions to: :active; end
        event :inactivate do; transitions to: :inactive; end
        event :archive do;    transitions to: :archived; end
      end

      include ::Totem::PubSub::Client
      # totem_pubsub debug: true

      # ##################################
      # ### Server Event Record Class. ###
      # ##################################
      class Record

        COLUMN_METHODS = [:authable, :user, :origin, :channel, :event, :room_event, :room, :rooms, :value, :records, :timer_settings, :timer_start_at, :timer_end_at]

        attr_reader :server_event, :pubsub, :error_class, :save_record

        def initialize(options={})
          @server_event = ::Thinkspace::PubSub::ServerEvent.new
          @rooms        = Array.new
          @action       = nil
          @pubsub       = server_event.class.totem_pubsub
          set_error_class
          save_record_on
          options.present? ? with_options(options) : init_defaults
        end

        def init_defaults; channel; room_event; end

        # ###
        # ### Chainable Methods (some methods have aliases).
        # ###

        def save; save_error unless server_event.save; self; end

        def publish
          save if server_event.new_record? && save_record
          value = get_publish_value
          timer = get_publish_timer
          pubsub.data
            .to(server_event.rooms)
            .room_event(server_event.room_event)
            .value(value)
            .timer(timer)
            .action(@action)
            .publish
          self
        end

        def channel(val=nil);    server_event.channel    = val || pubsub.channel_name; self; end
        def room_event(val=nil); server_event.room_event = val || :server_event; self; end
        def action(val=nil);     @action = val || nil; self; end

        def authable(val); server_event.authable = val; self; end
        def user(u);       server_event.user_id  = u.present? ? u.id : nil; self; end
        def origin(val);   server_event.origin   = val.is_a?(Class) ? val.name : val.class.name; self; end

        def timer_settings(val);  server_event.timer_settings = val; self; end
        def timer_start_at(val);  server_event.timer_start_at = val; self; end
        def timer_end_at(val);    server_event.timer_end_at   = val; self; end

        def value(val);   server_event.value = val; self; end
        def event(val);   server_event.event = val; self; end
        def records(val); server_event.records = val; self; end

        def room(r)
          return self if r.blank?
          r.is_a?(Array) ? @rooms += r : @rooms.push(r)
          server_event.rooms = @rooms.uniq
          self
        end
        alias :rooms :room

        def room_for(rs, *args); room pubsub.room_for(rs, *args); self; end

        def with_options(options)
          opts = options.symbolize_keys
          COLUMN_METHODS.each do |m|
            self.send m, opts[m]  if self.respond_to?(m)
          end
        end

        def save_record_on;  @save_record = true;  self; end
        def save_record_off; @save_record = false; self; end

        def on_error(klass); @error_class = klass; self; end

        private

        # ###
        # ### Publish Helpers.
        # ###

        def get_publish_value
          return nil unless (server_event.value.present? || server_event.event.present? || server_event.records.present?)
          value = (server_event.value || Hash.new).deep_dup
          value.merge!(event: server_event.event)      if server_event.event.present?
          value.merge!(records: server_event.records)  if server_event.records.present?
          value
        end

        def get_publish_timer
          return nil if server_event.timer_settings.blank?
          id    = pubsub.room_for(server_event)
          timer = server_event.timer_settings.deep_dup
          timer.merge!(id: id, start_at: server_event.timer_start_at, end_at: server_event.timer_end_at)
          timer.merge!(user_id: server_event.user_id) unless timer[:user_id].present?
          timer
        end

        # ###
        # ### Errors.
        # ###

        def set_error_class(klass=nil); @error_class = klass || SaveError; end

        def save_error
          message  = "Server event save error."
          message += "\nValidation errors: #{server_event.errors.messages}"
          message += "\nServerEvent: #{server_event.inspect}"
          raise error_class, message
        end

        class SaveError < StandardError; end

      end
      # ######################################
      # ### End Server Event Record Class. ###
      # ######################################

      class RePublish < Record
        def initialize
          @pubsub = Thinkspace::PubSub::ServerEvent.totem_pubsub
          set_error_class
        end
        def republish(server_events)
          return if server_events.blank?
          Array.wrap(server_events).each do |server_event|
            @server_event = server_event
            publish
          end
        end
      end

    end
  end
end
