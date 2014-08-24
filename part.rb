class Part < Struct.new(:name, :weapon_skill, :strength, :toughness, :wounds, :initiative, :attacks, :leadership, :armor_save, :ward_save, :equipment)
  def model
    @_model
  end

  def model=(new_value)
    @_model = new_value
  end
end

