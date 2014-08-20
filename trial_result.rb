class TrialResult < Struct.new(:outcome, :round_results)
  def wounds_caused_by_attacker
    round_results.inject(0) { |sum, result| sum + result.wounds_caused_by_attacker }
  end

  def wounds_caused_by_defender
    round_results.inject(0) { |sum, result| sum + result.wounds_caused_by_defender }
  end

  def number_of_rounds
    round_results.size
  end
end

