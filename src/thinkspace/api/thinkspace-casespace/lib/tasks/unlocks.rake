namespace :thinkspace do
  namespace :casespace do
    namespace :phases do

      task :unlock_cron, [] => [:environment] do |t, args|
        schedule_unlock
      end

      def schedule_unlock
        # 10.minutes is the CRON interval.
        # => This approach has a failsafe to catch anything that did not run in the past.
        # => Being exact is not needed.
        debug = false
        time  = Time.now + 10.minutes 
        tts   = Thinkspace::Common::Timetable.
                      scope_by_phase.
                      scope_unlock_at_before(time).
                      scope_not_unlocked
        return if tts.empty?
        tts.each do |tt|
          # Get ownerable, get unlock at, schedule for then.
          ownerable = tt.ownerable
          phase     = tt.timeable
          run_at    = tt.unlock_at || Time.now
          if ownerable.present?
            # Has an ownerable, process with this in mind.
            puts "\n Ownerable present (#{ownerable.id}) - run_at: #{run_at} - phase_id: #{phase.id} \n" if debug
            phase.delay(run_at: run_at).unlock_for_ownerable(ownerable, tt)
          else
            # Has no ownerable, process like a class-wide unlock.
            puts "\n No ownerable present - run_at: #{run_at} - phase_id: #{phase.id} \n" if debug
            tts = tts.scope_no_ownerable
            puts "\n Starting no ownerable DJ with tts: #{tts.inspect} \n" if debug
            phase.delay(run_at: run_at).unlock_valid_locked_ownerable_phase_states(tts.pluck(:id), tt)
          end
        end

      end

    end
  end
end
