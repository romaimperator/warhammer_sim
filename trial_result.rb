class TrialResult < Struct.new(:outcome, :round_results, :attacker_size, :defender_size)
  def attacker_survivors
    attacker_size
  end

  def defender_survivors
    defender_size
  end

  def hits_caused_by_attacker_each_round
    round_results.map(&:hits_caused_by_attacker)
  end

  def wounds_caused_by_attacker_each_round
    round_results.map(&:wounds_caused_by_attacker)
  end

  def unsaved_wounds_caused_by_attacker_each_round
    round_results.map(&:unsaved_wounds_caused_by_attacker)
  end

  def wounds_caused_by_attacker
    round_results.inject(0) { |sum, result| sum + result.unsaved_wounds_caused_by_attacker }
  end

  def hits_caused_by_defender_each_round
    round_results.map(&:hits_caused_by_defender)
  end

  def wounds_caused_by_defender_each_round
    round_results.map(&:wounds_caused_by_defender)
  end

  def unsaved_wounds_caused_by_defender_each_round
    round_results.map(&:unsaved_wounds_caused_by_defender)
  end

  def wounds_caused_by_defender
    round_results.inject(0) { |sum, result| sum + result.unsaved_wounds_caused_by_defender }
  end

  def number_of_rounds
    round_results.size
  end
end

