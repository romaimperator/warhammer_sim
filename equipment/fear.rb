require "equipment/base"

module Equipment
  class Fear < Base
    attr_reader :failed_this_round

    def initialize
      @failed_this_round = false
    end

    def before_combat(round_number, unit, target_unit)
      leadership_roll = DieRoller.sum_roll(2)
      if leadership_roll > unit.leadership
        @failed_this_round = true
      end
    end

    def after_combat(round_number, unit, target_unit)
      @failed_this_round = false
    end

    def weapon_skill(round_number, current_weapon_skill)
      if @failed_this_round
        1
      else
        current_weapon_skill
      end
    end
  end
end
