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
    rounds = 0
    while fighting
      rounds += 1
      result = @round_runner.simulate(attacking_unit, defending_unit)
      @results[result] += 1
      if result == ATTACKER_WIN
        fighting = false
      elsif result == DEFENDER_WIN
        fighting = false
      elsif result == ATTACKER_FLEE
        fighting = false
      elsif result == DEFENDER_FLEE
        fighting = false
      elsif result == BOTH_DEAD
        fighting = false
      elsif result == ATTACKER_HOLD
      elsif result == DEFENDER_HOLD
      elsif result == TIE
      else
        raise Exception.new("Bad result")
      end
    end
    rounds
  end
end

