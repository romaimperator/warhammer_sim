require_relative 'equipment'

class ExtraHandWeapon < Equipment
  def attacks(round_number, current_attacks, unit)
    current_attacks + 1
  end
end

