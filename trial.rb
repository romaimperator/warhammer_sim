require_relative 'trial_result'

class Trial
  attr_reader :results

  def initialize(round_runner, &block)
    @setup_combat = block
    @round_runner = round_runner
    @results = {
      ATTACKER_WIN => 0,
      DEFENDER_WIN => 0,
      ATTACKER_FLEE => 0,
      DEFENDER_FLEE => 0,
      ATTACKER_HOLD => 0,
      DEFENDER_HOLD => 0,
      TIE => 0,
      BOTH_DEAD => 0
    }
  end

  def simulate
    attacking_unit, defending_unit = @setup_combat.call
    fighting = true
    rounds = []
    while fighting
      result = @round_runner.simulate(attacking_unit, defending_unit)
      rounds << result
      @results[result.outcome] += 1
      if result.outcome == ATTACKER_WIN
        fighting = false
      elsif result.outcome == DEFENDER_WIN
        fighting = false
      elsif result.outcome == ATTACKER_FLEE
        fighting = false
      elsif result.outcome == DEFENDER_FLEE
        fighting = false
      elsif result.outcome == BOTH_DEAD
        fighting = false
      elsif result.outcome == ATTACKER_HOLD
      elsif result.outcome == DEFENDER_HOLD
      elsif result.outcome == TIE
      else
        raise Exception.new("Bad result")
      end
    end
    TrialResult.new(rounds.last.outcome, rounds)
  end
end

