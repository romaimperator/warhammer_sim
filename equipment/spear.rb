require "equipment/base"

module Equipment
  class FootSpear < Base
    def attacks(round_number, current_attacks, unit, rank)
      if (unit.is_horde? && rank == 4) || rank <= 3
        current_attacks
      else
        0
      end
    end
  end

  class MountedSpear < Base
    def strength(round_number, current_strength)
      if round_number == 1
        current_strength + 1
      else
        current_strength
      end
    end
  end
end

