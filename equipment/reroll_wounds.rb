require "equipment/base"

module Equipment
  class RerollWounds < Base
    def wound_reroll_values(round_number, reroll_values, wound_needed)
      reroll_values + (1...wound_needed).to_a
    end
  end
end

