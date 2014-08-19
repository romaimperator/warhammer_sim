class Round
  attr_reader :results

  def initialize(&block)
    @setup_combat = block
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
    attacking_unit, defending_unit = setup_combat
    fighting = true
    rounds = 0
    while fighting
      rounds += 1
      result = simulate_round(attacking_unit, defending_unit)
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

  def setup_combat
    @setup_combat.call
  end
end

