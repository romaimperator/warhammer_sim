require_relative "trial_result"

# This class is responsible for managing a single trial of combat between two
# units and collecting the results.
class Trial
  attr_reader :results

  def initialize(&block)
    @attacking_unit, @defending_unit = block.call
    @rounds = []
  end

  def simulate
    loop do
      result =
        Round.new(@rounds.size + 1, @attacking_unit, @defending_unit).simulate
      @rounds << result
      p result
      p stop_fighting?(result)
      break if stop_fighting?(result)
    end
    p "End of trial"
    p(TrialResult.new(@rounds.last.outcome, @rounds, @attacking_unit.model_count,
                    @defending_unit.model_count))
  end

  def stop_fighting?(result)
    case result.outcome
    when :attacker_win, :defender_win, :attacker_flee, :defender_flee, :both_dead
      true
    when :attacker_hold, :defender_hold, :tie
      false
    else
      fail Exception, "Bad result: #{result}"
    end
  end
end

