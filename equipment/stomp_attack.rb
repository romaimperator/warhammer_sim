module Equipment
  class StompAttack < Base
    def initiative_steps(round_number, current_initiative_steps)
      current_initiative_steps | [ALWAYS_STRIKE_LAST_INITIATIVE_VALUE]
    end

    def matchups_for_initiative(round_number, current_matchups, initiative_value, attacks, picked_target)
      if initiative_value == ALWAYS_STRIKE_LAST_INITIATIVE_VALUE
        current_matchups + [AttackMatchup.new(round_number, owner, attacks, picked_target)]
      else
        current_matchups
      end
    end
  end
end
