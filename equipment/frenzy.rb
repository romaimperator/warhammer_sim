require "equipment/base"

module Equipment
  class Frenzy < Base
    def combat_round_lost(round_number, unit)
      owner.remove_equipment(self)
    end

    def attacks(round_number, current_attacks, unit, rank)
      current_attacks + 1
    end
  end
end
