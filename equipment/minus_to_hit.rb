require "equipment/base"

module Equipment
  class MinusToHit < Base
    def initialize(penalty)
      @penalty = penalty
    end

    def hit_needed(round_number, roll_needed)
      [roll_needed + @penalty, 6].min
    end
  end
end
