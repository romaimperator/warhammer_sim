require "equipment/base"

module Equipment
  class ExtraHandWeapon < Base
    def attacks(round_number, current_attacks, unit, rank)
      current_attacks + 1
    end
  end
end

