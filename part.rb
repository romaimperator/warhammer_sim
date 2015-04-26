class Part < Struct.new(:name, :_weapon_skill, :_strength, :_toughness, :_wounds, :_initiative, :_attacks, :_leadership, :_armor_save, :_ward_save, :equipment)
  attr_accessor :model

  def initialize(*args, &block)
    super
    @manipulations_store = {}
  end

  def add_equipment(equipment)
    self.equipment += equipment
  end

  def weapon_skill
    item_manipulation(:weapon_skill, _weapon_skill)
  end

  def strength
    item_manipulation(:strength, _strength)
  end

  def toughness
    item_manipulation(:toughness, _toughness)
  end

  def wounds
    item_manipulation(:wounds, _wounds)
  end

  def initiative(defender)
    item_manipulation(:initiative, _initiative, defender)
  end

  def attacks
    item_manipulation(:attacks, _attacks, model.unit)
  end

  def leadership
    item_manipulation(:leadership, _leadership)
  end

  def armor_save
    item_manipulation(:armor_save, _armor_save)
  end

  def ward_save
    item_manipulation(:ward_save, _ward_save)
  end

  def dead?
    wounds <= 0
  end

  def take_wounds(wounds_caused)
    _wounds -= wounds_caused
    if dead?
      model.notify_part_died(self)
    end
  end

  private

  def item_manipulation(method_name, starting_value, *args)
    compute_value_block = Proc.new do
      result = starting_value
      equipment.each do |item|
        result = item.send(method_name, model.unit.round_number, result, *args)
      end
      result
    end
    if !@manipulations_store[method_name]
      @manipulations_store[method_name] = {}
    end
    @manipulations_store[method_name][model.unit.round_number] ||= compute_value_block.call
  end

end

