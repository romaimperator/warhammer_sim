require "equipment/base"

module Equipment
  class SwordOfStriking < Base
    def hit_needed(round_number, roll_needed)
      [roll_needed - 1, 2].max # +1 to hit
    end
  end
end

