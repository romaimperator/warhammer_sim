class TrialResult < Struct.new(:outcome, :round_results, :attacker_size, :defender_size)
  def attacker_survivors
    if attacker_size != 0
      attacker_size
    else
      nil
    end
  end

  def defender_survivors
    if defender_size != 0
      defender_size
    else
      nil
    end
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

