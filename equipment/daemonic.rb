require "equipment/base"

module Equipment
  class Daemonic < Base
    attr_reader :wounds_taken_this_round

    def initialize
      @wounds_taken_this_round = 0
    end

    def taken_wounds(round_number, current_wounds_taken)
      @wounds_taken_this_round = current_wounds_taken
    end

    def check_break_test(round_number, current_break_test_result, break_test_roll, modifier, unit)
      if break_test_roll != 12
        if break_test_roll == 2
          # heal up daemon unit for all lost wounds this round
          unit.restore_wounds(@wounds_taken_this_round)
        end

        # Take wounds lost from daemonic rule
        modified_leadership = [unit.leadership - modifier, 0].max
        additional_wounds = [break_test_roll - modified_leadership, 0].max
        if additional_wounds > 0
          unit.take_wounds(additional_wounds)
        end
      else
        # destroy entire daemon unit
        unit.destroy
      end

      # Always return false since daemon units never break
      false
    end
  end
end
