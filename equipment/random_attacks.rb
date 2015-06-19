require "equipment/base"

module Equipment
  class RandomAttacks < Base
    def initialize(number_of_dice)
      @number_of_dice = number_of_dice
    end

    def attacks(round_number, current_attacks, unit, rank)
      DieRoller.sum_roll(@number_of_dice) + current_attacks
    end
  end
end
