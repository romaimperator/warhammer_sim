require File.expand_path(File.dirname(__FILE__) + "../../../part")
require_relative "../../equipment/halberd"

class PartFactory
  attr_accessor :name
  attr_accessor :weapon_skill
  attr_accessor :strength
  attr_accessor :toughness
  attr_accessor :wounds
  attr_accessor :initiative
  attr_accessor :attacks
  attr_accessor :leadership
  attr_accessor :armor_save
  attr_accessor :ward_save
  attr_accessor :equipment

  def initialize
    @name = "man"
    @weapon_skill = 3
    @strength = 3
    @toughness = 3
    @wounds = 1
    @initiative = 3
    @attacks = 1
    @leadership = 7
    @armor_save = 6
    @ward_save = 7
    @equipment = [Halberd.new]
  end

  def build
    Part.new(@name, @weapon_skill, @strength, @toughness, @wounds, @initiative,
             @attacks, @leadership, @armor_save, @ward_save, @equipment)
  end

  def name(name)
    @name = name
    self
  end

  def weapon_skill(weapon_skill)
    @weapon_skill = weapon_skill
    self
  end

  def strength(strength)
    @strength = strength
    self
  end

  def toughness(toughness)
    @toughness = toughness
    self
  end

  def initiative(initiative)
    @initiative = initiative
    self
  end

  def attacks(attacks)
    @attacks = attacks
    self
  end

  def leadership(leadership)
    @leadership = leadership
    self
  end

  def armor_save(armor_save)
    @armor_save = armor_save
    self
  end

  def ward_save(ward_save)
    @ward_save = ward_save
    self
  end

  def equipment(equipment)
    @equipment = equipment
    self
  end
end

