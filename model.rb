class Model < Struct.new(:name, :weapon_skill, :strength, :toughness, :wounds, :initiative, :attacks, :leadership, :armor_save, :ward_save, :mm_width, :mm_length)
  def dead?
    wounds <= 0
  end

  def strike_first?
    false
  end
end

