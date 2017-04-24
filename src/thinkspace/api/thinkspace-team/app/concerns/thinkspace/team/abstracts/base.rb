module Thinkspace; module Team; module Abstracts
  class Base

    # Take an array of plucked values and return it in hash form based on the keys.
    def pluck_to_hash(values, keys)
      values.map { |value| Hash[keys.zip(value)] }
    end

  end
end; end; end