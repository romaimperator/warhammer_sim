Stats = Struct.new(:weapon_skill, :strength, :toughness, :wounds, :initiative,
                   :attacks, :leadership, :armor_save, :ward_save)

AttackStats = Struct.new(:weapon_skill, :strength)
DefendStats = Struct.new(:weapon_skill, :toughness, :armor_save, :ward_save)

