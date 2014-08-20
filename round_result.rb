class RoundResult < Struct.new(:outcome, :attacker_stats, :defender_stats)
  def wounds_caused_by_attacker
    attacker_stats.wounds_caused
  end

  def wounds_caused_by_defender
    defender_stats.wounds_caused
  end
end

