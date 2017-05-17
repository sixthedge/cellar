class Travis
  class Opentbl
    class Staging
      class Client

        def self.before_install
          puts "Opentbl::Staging::Client before_install..."
        end

        def self.install
          puts "Opentbl::Staging::Client install..."
        end

      end
    end
  end
end