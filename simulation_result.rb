SimulationResult = Struct.new(:trial_results) do
  def attacker_wins
    sum_results(:attacker_win)
  end

  def defender_wins
    sum_results(:defender_win)
  end

  def attacker_flee
    sum_results(:attacker_flee)
  end

  def defender_flee
    sum_results(:defender_flee)
  end

  def both_dead
    sum_results(:both_dead)
  end

  def sum_results(successful_outcomes)
    @trial_results.count { |result| result.outcome == successful_outcomes }
  end

  def attacker_wounds
    @trial_results.map(&:wounds_caused_by_attacker)
  end

  def defender_wounds
    @trial_results.map(&:wounds_caused_by_defender)
  end

  def attacker_wounds_each_round
    @trial_results.map(&:unsaved_wounds_caused_by_attacker_each_round)
  end

  def defender_wounds_each_round
    @trial_results.map(&:unsaved_wounds_caused_by_defender_each_round)
  end
end

