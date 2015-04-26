require_relative 'equipment'

class FootSpear < Equipment
  def attacks(round_number, current_attacks, unit)
    if unit.is_horde?
      current_attacks + unit.models_in_rank(4)
    else
      current_attacks + unit.models_in_rank(3)
    end
  end
end

class MountedSpear < Equipment
  def strength(round_number, current_strength)
    if round_number == 1
      current_strength + 1
    else
      current_strength
    end
  end
end

