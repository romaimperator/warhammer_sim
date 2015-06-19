Attack = Struct.new(:number, :weapon_skill, :strength, :equipment) do
  # Joins together all attacks that are compatible with each other
  # and returns them.
  #
  # attacks - array of Attack objects to join
  #
  # returns - an array of the fewest number of Attack objects which
  #           can represent all of the attacks
  def self.join(attacks)
    attacks.group_by { |attack| [attack.weapon_skill, attack.strength, attack.equipment] }.map do |chunk_values, attack_chunk|
      attack_chunk.reduce(Attack.new(0, *chunk_values), &:combine)
    end
  end

  # Combines two attacks together assuming they are compatible
  #
  # other - an Attack object to combine with
  #
  # returns - an array of the combined attacks. Does not
  #           combine attacks if they have differing strengths
  def combine(other)
    fail TypeError, "#{other} is not a compatible type with Attack" unless other.kind_of?(Attack)

    if weapon_skill == other.weapon_skill && strength == other.strength && equipment == other.equipment
      Attack.new(number + other.number, weapon_skill, strength, equipment)
    else
      fail TypeError, "#{self} and #{other} do not have compatible values"
    end
  end
end
