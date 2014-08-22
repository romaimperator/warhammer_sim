class RoundResult < Struct.new(:outcome, :attacker_stats, :defender_stats)
  def hits_caused_by_attacker
    attacker_stats.hits
  end

  def wounds_caused_by_attacker
    attacker_stats.wounds_caused
  end

  def unsaved_wounds_caused_by_attacker
    attacker_stats.unsaved_wounds
  end

  def hits_caused_by_defender
    defender_stats.hits
  end

  def wounds_caused_by_defender
    defender_stats.wounds_caused
  end

  def unsaved_wounds_caused_by_defender
    defender_stats.unsaved_wounds
  end
end

