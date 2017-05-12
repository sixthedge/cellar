module Test::Serializer::Mocks

  extend ActiveSupport::Concern

  included do

    def mock_counter(n=1, retval={})
      mock = MiniTest::Mock.new
      if n == 0
        mock.expect(:call, nil) do
          false  # fail if called
        end
      else
        n.times do
          mock.expect(:call, retval) do
            true
          end
        end
      end
      mock
    end

    def mock_for_keys(*args)
      mock = MiniTest::Mock.new
      args.each do |mock_key|
        case mock_key
        when :ability    then mock.expect(:call, {}) {|key, array| key == :ability}
        when :metadata   then mock.expect(:call, {}) {|key, array| key == :metadata}
        end
      end
      mock
    end

  end # included
end
