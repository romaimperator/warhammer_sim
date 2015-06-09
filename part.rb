Part = Struct.new(:name, :_weapon_skill, :_strength, :_toughness, :_wounds,
                  :_initiative, :_attacks, :_leadership, :_armor_save,
                  :_ward_save, :equipment) do
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

  def initiative(round_number)
    @round_number = round_number
    item_manipulation(:initiative, _initiative)
  end

  def attacks(round_number, rank)
    @round_number = round_number
    if rank == 1
      item_manipulation(:attacks, _attacks, model.unit, rank)
    elsif rank == 2
      1
    elsif rank == 3 && model.unit.is_horde?
      1
    else
      0
    end
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

  def hit_reroll_values(to_hit_number)
    reroll_values = item_manipulation(:hit_reroll_values, [], to_hit_number)
    reroll_values.uniq
  end

  def wound_reroll_values(to_wound_number)
    reroll_values = item_manipulation(:wound_reroll_values, [], to_wound_number)
    reroll_values.uniq
  end

  def dead?
    wounds <= 0
  end

  def take_wounds(wounds_caused)
    return if dead?

    if model == model.unit.model
      model.unit.take_wounds(wounds_caused)
    else
      self._wounds -= wounds_caused
      model.notify_part_died(self) if dead?
    end
  end

  private

  def item_manipulation(method_name, starting_value, *args)
    round_number = @round_number || model.unit.round_number
    compute_value_block = proc do
      result = starting_value
      equipment.each do |item|
        result = item.send(method_name, round_number, result, *args)
      end
      result
    end
    cache_fetch(method_name, round_number, &compute_value_block)
  end

  def cache_fetch(method_name, round_number, &compute_value_block)
    unless @manipulations_store[method_name]
      @manipulations_store[method_name] = {}
    end
    @manipulations_store[method_name][round_number] ||= compute_value_block.call
  end
end

