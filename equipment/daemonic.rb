module Equipment
  class Daemonic < Base
    def initialize
      @wounds_taken_this_round = 0
    end
    
    def taken_wounds(round_number, current_wounds_taken)
      @wounds_taken_this_round = current_wounds_taken
    end
    
    def check_break_test(round_number, current_break_test_result, break_test_roll, modifier, unit)
      case break_test_roll
      when 2
        # heal up daemon unit for all lost wounds this round
        unit.restore_wounds(@wounds_taken_this_round)
      when 12
        # destroy entire daemon unit
        unit.destroy
      end
      # Take wounds lost from daemonic rule
      additional_wounds = [break_test_roll - unit.leadership - modifier, 0].max
      if additional_wounds > 0
        unit.take_wounds(additional_wounds)
      end

      # Always return false since daemon units never break
      false
    end
  end
end
