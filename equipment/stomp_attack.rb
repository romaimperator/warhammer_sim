require "equipment/base"
require "constants"

module Equipment
  class StompAttack < Base
    def initiative_steps(round_number, current_initiative_steps)
      current_initiative_steps | [ALWAYS_STRIKE_LAST_INITIATIVE_VALUE]
    end

    def pending_attacks(round_number, current_pending_attacks, initiative_value)
      if initiative_value == ALWAYS_STRIKE_LAST_INITIATIVE_VALUE
        current_pending_attacks + [owner.make_attack(round_number: round_number, number: 1, weapon_skill: :auto_hit)]
      else
        current_pending_attacks
      end
    end
  end
end
