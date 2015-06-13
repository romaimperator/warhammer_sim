require "equipment/base"

module Equipment
  class MurderousProwess < Base
    def wound_reroll_values(round_number, reroll_values, wound_needed)
      reroll_values + [1]
    end
  end
end

