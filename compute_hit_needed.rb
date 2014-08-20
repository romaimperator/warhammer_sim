class ComputeHitNeeded
  def self.hit_needed(attacker_weapon_skill, defender_weapon_skill)
    if attacker_weapon_skill - defender_weapon_skill > 0
      3
    elsif defender_weapon_skill > (2 * attacker_weapon_skill)
      5
    else
      4
    end
  end
end

