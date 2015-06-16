module Equipment
  class RandomAttacks < Base
    def initialize(number_of_dice)
      @number_of_dice = number_of_dice
    end

    def attacks(round_number, current_attacks, unit, rank)
      if rank == 1
        sum_roll(@number_of_dice) + current_attacks
      else
        fail NotYetImplemented
      end
    end
  end
end
