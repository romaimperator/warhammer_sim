module Equipment
  class Fear < Base
    def initialize
      @failed_this_round = false
    end
    
    def before_combat(round_number, unit, target_unit)
      leadership_roll = sum_roll(2)
      puts "roll: #{leadership_roll}"
      if leadership_roll > unit.leadership
        @failed_this_round = true
      end
    end

    def weapon_skill(round_number, current_weapon_skill)
      if @failed_this_round
        # fail RuntimeErorr, "The witch elves failed a fear test."
        @failed_this_round = false
        1
      else
        current_weapon_skill
      end
    end
  end
end
